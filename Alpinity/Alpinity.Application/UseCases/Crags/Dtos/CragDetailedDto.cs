using Alpinity.Application.Dtos;

namespace Alpinity.Application.UseCases.Crags.Dtos;

public class CragDetailedDto
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public string Description { get; set; } = null!;
    public required PointDto Location { get; set; }
    // public required ICollection<SectorInfoDto> Sectors { get; set; }
    public required ICollection<string> Images { get; set; }
}