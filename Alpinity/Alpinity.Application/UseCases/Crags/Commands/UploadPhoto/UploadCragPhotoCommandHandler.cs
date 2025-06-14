using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.UploadPhoto;

public class UploadCragPhotoCommandHandler(
    ICragRepository cragRepository,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository,
    IMapper mapper) : IRequestHandler<UploadCragPhotoCommand>
{
    public async Task Handle(UploadCragPhotoCommand request, CancellationToken cancellationToken)
    {
        var crag = await cragRepository.GetCragById(request.CragId, cancellationToken) ?? throw new EntityNotFoundException("Crag not found.");

        if (crag.Photos.Count >= 15) throw new BadRequestException("Crag already has 15 photos.");

        var photoFile = mapper.Map<FileRequest>(request.Photo);

        var photoUrl = await fileRepository.UploadPrivateFileAsync(photoFile, cancellationToken);

        var photo = await photoRepository.AddImage(new Photo
        {
            Url = photoUrl
        }, cancellationToken);

        crag.Photos ??= new List<Photo>();
        crag.Photos.Add(photo);

        await cragRepository.UpdateCrag(crag, cancellationToken);
    }
}