using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.UpdatePhoto;

public class UpdateUserPhotoCommandHandler(
    IUserRepository userRepository,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository,
    IMapper mapper) : IRequestHandler<UpdateUserPhotoCommand>
{
    public async Task Handle(UpdateUserPhotoCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetByIdAsync(request.UserId, cancellationToken);
        if (user == null) throw new EntityNotFoundException("User not found.");

        var photoFile = mapper.Map<FileRequest>(request.Photo);

        var photoUrl = await fileRepository.UploadPrivateFileAsync(photoFile, cancellationToken);

        var photo = await photoRepository.AddImage(new Photo
        {
            Url = photoUrl
        }, cancellationToken);

        user.ProfilePhoto = photo;

        await userRepository.UpdateUser(user, cancellationToken);
    }
}