using Alpinity.Domain.Enums;

namespace Alpinity.Domain.Entities;

public class Route
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public string? Description { get; set; }
    public ClimbingGrade? Grade { get; set; } = ClimbingGrade.PROJECT;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public RouteType RouteType { get; set; }
    public int? Length { get; set; }

    public Guid SectorId { get; set; }
    public Sector? Sector { get; set; }

    public ICollection<RoutePhoto>? RoutePhotos { get; set; }
}