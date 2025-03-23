using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Application.UseCases.Sectors.Dtos;

namespace Alpinity.Application.UseCases.Crags.Dtos;

public class CragDetailedDto
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public PointDto? Location { get; set; }
    public string? LocationName { get; set; }
    public ICollection<SectorDetailedDto> Sectors { get; set; }
    public ICollection<PhotoDto> Photos { get; set; }
}