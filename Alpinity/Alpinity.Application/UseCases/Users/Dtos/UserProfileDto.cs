using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Users.Dtos;

public class UserProfileDto
{
    public Guid Id { get; set; }
    public string Username { get; set; } = null!;
    public string? Email { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public int? CragsVisited { get; set; }
    public Dictionary<RouteType, Dictionary<AscentType, int>> RouteTypeAscentCount { get; set; } = new Dictionary<RouteType, Dictionary<AscentType, int>>();
    public Dictionary<ClimbingGrade, int> ClimbingGradesCount { get; set; } = new Dictionary<ClimbingGrade, int>();
    public ICollection<PhotoDto> Photos { get; set; } = new List<PhotoDto>();

    // TODO: Add friends support
} 