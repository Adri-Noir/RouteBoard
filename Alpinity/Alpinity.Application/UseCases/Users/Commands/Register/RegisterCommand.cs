using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.UseCases.Users.Commands.Register;

public class RegisterCommand : IRequest<LoggedInUserDto>
{
    public required string Email { get; set; }
    public required string Username { get; set; }
    public required string Password { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public DateTime DateOfBirth { get; set; }
    public IFormFile? ProfilePhoto { get; set; }

    [JsonIgnore]
    public string NormalizedEmail
        => Email.Trim().ToLower();
}