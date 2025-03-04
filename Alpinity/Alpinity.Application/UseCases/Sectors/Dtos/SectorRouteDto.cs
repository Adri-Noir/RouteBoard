using System;
using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Sectors.Dtos;

public class SectorRouteDto
{
    public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string? Description { get; set; }
    public ClimbingGrade? Grade { get; set; }
    public string CreatedAt { get; set; }
    public ICollection<RouteType>? RouteType { get; set; }
    public int? Length { get; set; }
    
    public ICollection<RoutePhotoDto> RoutePhotos { get; set; }
    public int? AscentsCount { get; set; }
}
