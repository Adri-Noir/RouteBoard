using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Services;
using Alpinity.Application.UseCases.Users.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.Login;

public class LoginCommandHandler(
    IUserRepository userRepository,
    ISignInService signInService,
    IMapper mapper) : IRequestHandler<LoginCommand, LoggedInUserDto>
{
    public async Task<LoggedInUserDto> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var user = request.NormalizedUsernameOrEmail.Contains('@')
            ? await userRepository.GetByEmailAsync(request.NormalizedUsernameOrEmail)
            : await userRepository.GetByUsernameAsync(request.NormalizedUsernameOrEmail);

        if (user is null) throw new UnAuthorizedAccessException("Invalid username/email or password.");

        if (!signInService.CheckPasswordHash(user.PasswordHash, request.Password))
            throw new UnAuthorizedAccessException("Invalid username/email or password.");

        var result = mapper.Map<LoggedInUserDto>(user);

        result.Token = signInService.GenerateJwToken(user);

        return result;
    }
}