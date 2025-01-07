namespace Alpinity.Application.UseCases.Users.Dtos;

public class UserDto
{
    public Guid Id { get; set; }
    public string Username { get; set; }
    public string Email { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string DateOfBirth { get; set; }
    public string CreatedAt { get; set; }
    public string ProfilePhotoUrl { get; set; }
}