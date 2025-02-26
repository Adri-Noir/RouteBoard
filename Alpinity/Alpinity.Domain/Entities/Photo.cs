using System.ComponentModel.DataAnnotations;

namespace Alpinity.Domain.Entities;

public class Photo
{
    public Guid Id { get; set; }
    [StringLength(1000)]
    public string? Description { get; set; }
    [StringLength(500)]
    public required string Url { get; set; }
    public DateTime TakenAt { get; set; } = DateTime.UtcNow;

    public Guid? TakenByUserId { get; set; }
    public User? TakenByUser { get; set; }

    public Guid? CragId { get; set; }
    public Crag? Crag { get; set; }

    public Guid? SectorId { get; set; }
    public Sector? Sector { get; set; }

    public Guid? RouteImageId { get; set; }
    public RoutePhoto? RouteImage { get; set; }

    public Guid? RoutePathLineId { get; set; }
    public RoutePhoto? RoutePathLine { get; set; }

    public Guid? UserPhotoId { get; set; }
    public User? UserPhoto { get; set; }
}