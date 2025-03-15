using Alpinity.Application.Dtos;

namespace Alpinity.Application.UseCases.Map.Dtos;

public class GlobeSectorResponseDto
{
    public Guid Id { get; set; }
    public Guid CragId { get; set; }
    public string Name { get; set; }
    public string ImageUrl { get; set; }
    public PointDto Location { get; set; }
}
