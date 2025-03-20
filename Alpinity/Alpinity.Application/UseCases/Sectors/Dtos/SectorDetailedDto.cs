using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.UseCases.Sectors.Dtos;

public class SectorDetailedDto
{
    public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string Description { get; set; } = null!;
    public PointDto? Location { get; set; }
    public ICollection<PhotoDto> Photos { get; set; } = null!;
    public ICollection<SectorRouteDto> Routes { get; set; } = null!;
    public Guid CragId { get; set; }
    public string CragName { get; set; } = null!;
}