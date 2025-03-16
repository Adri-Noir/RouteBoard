using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Users.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.Me;

public class MeCommandHandler(
    IUserRepository userRepository,
    IMapper mapper) : IRequestHandler<MeCommand, LoggedInUserDto>
{
    public async Task<LoggedInUserDto> Handle(MeCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetByIdAsync(request.UserId, cancellationToken);
        if (user is null) throw new UnAuthorizedAccessException("Invalid User ID");

        var result = mapper.Map<LoggedInUserDto>(user);

        result.Token = request.Token;

        return result;
    }
}