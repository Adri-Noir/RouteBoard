namespace Alpinity.Application.UseCases.Photos.Dtos;

public class AllRoutePhotoDto
{
    public required Guid Id { get; set; }
    public required Guid RouteId { get; set; }
    public required PhotoDto Image { get; set; }
    public required PhotoDto PathLine { get; set; }
    public required PhotoDto CombinedPhoto { get; set; }
}