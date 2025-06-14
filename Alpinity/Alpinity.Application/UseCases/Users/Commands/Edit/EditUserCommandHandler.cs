using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Services;
using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using FluentValidation;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.Edit;

public class EditUserCommandHandler(
    IUserRepository userRepository,
    IAuthenticationContext authenticationContext,
    ISignInService signInService,
    IMapper mapper) : IRequestHandler<EditUserCommand, UserProfileDto>
{
    public async Task<UserProfileDto> Handle(EditUserCommand request, CancellationToken cancellationToken)
    {
        var currentUserId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
        var userRole = authenticationContext.GetUserRole();

        if (userRole != UserRole.Admin && currentUserId != request.UserId)
        {
            throw new UnAuthorizedAccessException("You are not authorized to edit this user profile.");
        }

        var user = await userRepository.GetUserProfileAsync(request.UserId, cancellationToken) ?? throw new EntityNotFoundException("User not found.");

        if (request.Username != null && request.Username != user.Username)
        {
            var existingUserWithUsername = await userRepository.GetByUsernameAsync(request.Username, cancellationToken);
            if (existingUserWithUsername != null)
            {
                throw new EntityAlreadyExistsException("A user with this username already exists.");
            }
            user.Username = request.Username;
        }

        if (request.Email != null && request.Email.Trim().ToLower() != user.Email.ToLower())
        {
            var normalizedEmail = request.Email.Trim().ToLower();
            var existingUserWithEmail = await userRepository.GetByEmailAsync(normalizedEmail, cancellationToken);
            if (existingUserWithEmail != null)
            {
                throw new EntityAlreadyExistsException("A user with this email already exists.");
            }
            user.Email = normalizedEmail;
        }

        if (request.Password != null)
        {
            user.PasswordHash = signInService.HashPassword(request.Password);
        }

        if (request.FirstName != null)
            user.FirstName = request.FirstName;
        if (request.LastName != null)
            user.LastName = request.LastName;
        if (request.DateOfBirth != null)
            user.DateOfBirth = DateTime.SpecifyKind(request.DateOfBirth.Value, DateTimeKind.Utc);

        await userRepository.UpdateUser(user, cancellationToken);

        return mapper.Map<UserProfileDto>(user);
    }
}