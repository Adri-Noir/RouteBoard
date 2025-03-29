using Alpinity.Application.UseCases.Users.Dtos;

namespace Alpinity.Application.UseCases.Photos.Dtos;

public class PhotoDto
{
    public required Guid Id { get; set; }
    // public string? Description { get; set; }
    public required string Url { get; set; }
    public string TakenAt { get; set; }
    // public UserDto TakenByUser { get; set; }
}