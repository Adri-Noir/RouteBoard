using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Users.Dtos;

public class LoggedInUserDto
{
    public required Guid Id { get; set; }
    public required string Email { get; set; }
    public required string Username { get; set; }
    public PhotoDto? ProfilePhoto { get; set; }
    public UserRole Role { get; set; }
    public string Token { get; set; }
}