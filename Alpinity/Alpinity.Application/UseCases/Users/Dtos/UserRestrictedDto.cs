namespace Alpinity.Application.UseCases.Users.Dtos;

public class UserRestrictedDto
{
    public Guid Id { get; set; }
    public string Username { get; set; } = null!;
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
}