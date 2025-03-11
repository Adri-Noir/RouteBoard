using System.ComponentModel.DataAnnotations;
using NetTopologySuite.Geometries;

namespace Alpinity.Domain.Entities;

public class Sector
{
    public Guid Id { get; set; }
    [StringLength(100)]
    public required string Name { get; set; }
    [StringLength(2000)]
    public string? Description { get; set; }
    
    public Point? Location { get; set; }
    
    public Guid CragId { get; set; }
    public Crag? Crag { get; set; }
    
    public ICollection<Route>? Routes { get; set; }
    public ICollection<Photo>? Photos { get; set; }
}