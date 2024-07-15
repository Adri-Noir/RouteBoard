namespace Alpinity.Domain.Entities;

public class Route
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public string? Description { get; set; }
    public string? Grade { get; set; }
    
    public Guid SectorId { get; set; }
    public Sector? Sector { get; set; }
    
    public ICollection<RoutePhoto>? RoutePhotos { get; set; }
}