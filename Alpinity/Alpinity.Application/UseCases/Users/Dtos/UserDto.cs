using Alpinity.Application.UseCases.Photos.Dtos;

namespace Alpinity.Application.UseCases.Users.Dtos;

public class UserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public DateTime DateOfBirth { get; set; }
    public DateTime CreatedAt { get; set; }
}