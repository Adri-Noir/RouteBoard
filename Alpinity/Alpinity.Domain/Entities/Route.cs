using Alpinity.Domain.Enums;
using System.ComponentModel.DataAnnotations;

namespace Alpinity.Domain.Entities;

public class Route
{
    public Guid Id { get; set; }
    [StringLength(100)]
    public required string Name { get; set; }
    [StringLength(2000)]
    public string? Description { get; set; }
    public ClimbingGrade? Grade { get; set; } = ClimbingGrade.PROJECT;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public ICollection<RouteType>? RouteType { get; set; }
    public int? Length { get; set; }

    public Guid SectorId { get; set; }
    public Sector? Sector { get; set; }

    public ICollection<RoutePhoto>? RoutePhotos { get; set; }
    
    public ICollection<Ascent>? Ascents { get; set; }
}