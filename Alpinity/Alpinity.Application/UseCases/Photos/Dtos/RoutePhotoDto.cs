namespace Alpinity.Application.UseCases.Photos.Dtos;

public class RoutePhotoDto
{
    public required Guid Id { get; set; }
    public Guid RouteId { get; set; }
    public PhotoDto Image { get; set; }
    public PhotoDto PathLine { get; set; }
    public PhotoDto CombinedPhoto { get; set; }
}