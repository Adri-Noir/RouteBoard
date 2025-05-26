using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.Edit;

public class EditUserCommand : IRequest<UserProfileDto>
{
    [JsonIgnore]
    public Guid UserId { get; set; }
    public string? Username { get; set; }
    public string? Email { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public string? Password { get; set; }
}