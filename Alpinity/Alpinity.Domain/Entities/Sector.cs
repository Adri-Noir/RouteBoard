namespace Alpinity.Domain.Entities;

public class Sector
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public string? Description { get; set; }
    
    public Guid CragId { get; set; }
    public Crag? Crag { get; set; }
    
    public ICollection<Route>? Routes { get; set; }
    public ICollection<Photo>? Photos { get; set; }
    
    
    // Blob storage for images
}