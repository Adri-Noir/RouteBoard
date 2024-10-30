using Alpinity.Application.UseCases.Routes.Dtos;

namespace Alpinity.Application.UseCases.Sectors.Dtos;

public class SectorDetailedDto
{
    public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string Description { get; set; } = null!;
    public ICollection<string> Photos { get; set; } = null!;
    public ICollection<RouteSimpleDto> Routes { get; set; } = null!;
    
    public Guid CragId { get; set; }
    public string CragName { get; set; } = null!;
}