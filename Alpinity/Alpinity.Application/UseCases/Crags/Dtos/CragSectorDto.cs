using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Photos.Dtos;

namespace Alpinity.Application.UseCases.Crags.Dtos;

public class CragSectorDto
{
 public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string Description { get; set; } = null!;
    public PointDto? Location { get; set; }
    public ICollection<PhotoDto> Photos { get; set; } = null!;
    public int RoutesCount { get; set; }
}
