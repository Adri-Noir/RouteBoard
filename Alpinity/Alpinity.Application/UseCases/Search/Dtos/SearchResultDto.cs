

using Alpinity.Application.Dtos;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Search.Dtos;


public class SearchResultDto
{   
    public Guid Id { get; set; }
    // Entity information
    public SearchResultItemType EntityType { get; set; }
    
    // Additional information based on entity type
    // Crag information
    public PointDto? CragLocation { get; set; }
    public Guid? CragId { get; set; }
    public string? CragName { get; set; }
    public int? CragRoutesCount { get; set; }
    public int? CragSectorsCount { get; set; }
    
    // Sector information
    public string? SectorName { get; set; }
    public Guid? SectorId { get; set; }
    public Guid? SectorCragId { get; set; }
    public string? SectorCragName { get; set; }
    public int? SectorRoutesCount { get; set; }
    
    // Route information
    public Guid? RouteId { get; set; }
    public ClimbingGrade? RouteDifficulty { get; set; }
    public string? RouteName { get; set; }
    public int? RouteAscentsCount { get; set; }
    public Guid? RouteSectorId { get; set; }
    public string? RouteSectorName { get; set; }
    public Guid? RouteCragId { get; set; }
    public string? RouteCragName { get; set; }
    
    // User profile information if a profile was viewed
    public Guid? ProfileUserId { get; set; }
    public string? ProfileUsername { get; set; }
}