using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.Login;

public class LoginCommand : IRequest<LoggedInUserDto>
{
    public required string EmailOrUsername { get; set; }

    [JsonIgnore]
    public string NormalizedUsernameOrEmail
        => EmailOrUsername.Trim().ToLower();

    public required string Password { get; set; }
}