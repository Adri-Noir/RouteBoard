using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Users.Dtos;

public class UserAscentDto : RouteCategoriesDto
{
    public Guid Id { get; set; }
    public string AscentDate { get; set; }
    public string? Notes { get; set; }
    public AscentType? AscentType { get; set; }
    public int? NumberOfAttempts { get; set; }
    public ClimbingGrade? ProposedGrade { get; set; }
    public int? Rating { get; set; }

    // Route information
    public Guid RouteId { get; set; }
    public string RouteName { get; set; }
    public ClimbingGrade? RouteGrade { get; set; }
    public string? RouteDescription { get; set; }
    public int? RouteLength { get; set; }
    public ICollection<RouteType>? RouteType { get; set; }

    // Sector and Crag information
    public Guid SectorId { get; set; }
    public string SectorName { get; set; }
    public Guid CragId { get; set; }
    public string CragName { get; set; }
} 