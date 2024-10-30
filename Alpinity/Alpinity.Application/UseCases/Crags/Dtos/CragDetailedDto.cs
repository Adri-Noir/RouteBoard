using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Sectors.Dtos;

namespace Alpinity.Application.UseCases.Crags.Dtos;

public class CragDetailedDto
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public string Description { get; set; } = null!;
    public required PointDto Location { get; set; }
    public ICollection<SectorSimpleDto> Sectors { get; set; } = null!;
    public ICollection<string> Photos { get; set; } = null!;
}