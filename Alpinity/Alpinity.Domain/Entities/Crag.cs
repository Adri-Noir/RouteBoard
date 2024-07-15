using NetTopologySuite.Geometries;

namespace Alpinity.Domain.Entities;

public class Crag
{
    public Guid Id { get; set; }
    
    public required string Name { get; set; }
    public string? Description { get; set; }
    public Point Location { get; set; }
    
    public ICollection<Sector>? Sectors { get; set; }
    
    public ICollection<Photo>? Photos { get; set; }
}