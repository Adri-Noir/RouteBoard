using Alpinity.Application.UseCases.Routes.Dtos;

namespace Alpinity.Application.UseCases.Sectors.Dtos;

public class SectorSimpleDto
{
    public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string Description { get; set; } = null!;
    public string Photo { get; set; } = null!;
    public ICollection<RouteSimpleDto> Routes { get; set; } = null!;
}