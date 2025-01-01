using Alpinity.Application.UseCases.Photos.Dtos;

namespace Alpinity.Application.UseCases.Routes.Dtos;

public class RouteDetailedDto
{
    public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string? Description { get; set; }
    public string? Grade { get; set; }
    public required Guid SectorId { get; set; }
    public required string SectorName { get; set; }
    public required Guid CragId { get; set; }
    public required string CragName { get; set; }
    public ICollection<RoutePhotoDto> RoutePhotos { get; set; }
}