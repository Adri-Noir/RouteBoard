using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Routes.Dtos;

public class RouteDetailedDto
{
    public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string? Description { get; set; }
    public ClimbingGrade? Grade { get; set; }
    public string CreatedAt { get; set; }
    public ICollection<RouteType>? RouteType { get; set; }
    public int? Length { get; set; }
    public required Guid SectorId { get; set; }
    public required string SectorName { get; set; }
    public required Guid CragId { get; set; }
    public required string CragName { get; set; }
    public ICollection<RoutePhotoDto> RoutePhotos { get; set; }
    public RouteCategoriesDto RouteCategories { get; set; }
    public ICollection<AscentDto>? Ascents { get; set; }
    public bool CanModify { get; set; } = false;
}