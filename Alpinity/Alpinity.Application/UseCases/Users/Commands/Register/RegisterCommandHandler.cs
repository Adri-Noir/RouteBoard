using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.Services;
using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using FluentValidation;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.Register;

public class RegisterCommandHandler(
    IUserRepository userRepository,
    ISignInService signInService,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository,
    IMapper mapper) : IRequestHandler<RegisterCommand, LoggedInUserDto>
{
    public async Task<LoggedInUserDto> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        if (await userRepository.GetByEmailAsync(request.NormalizedEmail, cancellationToken) != null)
            throw new EntityAlreadyExistsException("User with this email already exists");

        if (await userRepository.GetByUsernameAsync(request.Username, cancellationToken) != null)
            throw new EntityAlreadyExistsException("User with this username already exists");

        var passwordHash = signInService.HashPassword(request.Password);

        var photo = null as Photo;
        if (request.ProfilePhoto != null)
        {
            var photoFile = mapper.Map<FileRequest>(request.ProfilePhoto);
            var photoUrl = await fileRepository.UploadPrivateFileAsync(photoFile, cancellationToken);
            photo = await photoRepository.AddImage(new Photo
            {
                Url = photoUrl
            }, cancellationToken);
        }

        var user = new User
        {
            Email = request.NormalizedEmail,
            Username = request.Username,
            PasswordHash = passwordHash,
            FirstName = request.FirstName,
            LastName = request.LastName,
            DateOfBirth = DateTime.SpecifyKind(request.DateOfBirth, DateTimeKind.Utc)
        };

        if (photo != null)
            user.ProfilePhoto = photo;

        await userRepository.CreateAsync(user, cancellationToken);

        var result = mapper.Map<LoggedInUserDto>(user);
        result.Token = signInService.GenerateJwToken(user);

        return result;
    }
}