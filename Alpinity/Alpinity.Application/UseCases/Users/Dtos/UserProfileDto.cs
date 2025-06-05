using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Users.Dtos;

public class AscentCountDto
{
    public AscentType AscentType { get; set; }
    public int Count { get; set; }
}

public class GradeCountDto
{
    public ClimbingGrade ClimbingGrade { get; set; }
    public int Count { get; set; }
}

public class RouteTypeAscentCountDto
{
    public RouteType RouteType { get; set; }
    public List<AscentCountDto> AscentCount { get; set; } = new List<AscentCountDto>();
}

public class UserProfileDto
{
    public Guid Id { get; set; }
    public string Username { get; set; } = null!;
    public string? Email { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public PhotoDto? ProfilePhoto { get; set; }
    public int? CragsVisited { get; set; }
    public ICollection<RouteTypeAscentCountDto> RouteTypeAscentCount { get; set; } = new List<RouteTypeAscentCountDto>();
    public ICollection<GradeCountDto> ClimbingGradeAscentCount { get; set; } = new List<GradeCountDto>();
    public ICollection<PhotoDto> Photos { get; set; } = new List<PhotoDto>();
}