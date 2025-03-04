using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.Me;

public class MeCommand : IRequest<LoggedInUserDto>
{
    [JsonIgnore] public string? Token;
    [JsonIgnore] public Guid UserId;
}