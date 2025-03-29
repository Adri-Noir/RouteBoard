using System;

namespace Alpinity.Application.UseCases.Photos.Dtos;

public class ExtendedRoutePhotoDto
{
    public required Guid Id { get; set; }
    public Guid RouteId { get; set; }
    public PhotoDto Image { get; set; }
    public PhotoDto PathLine { get; set; }
}
