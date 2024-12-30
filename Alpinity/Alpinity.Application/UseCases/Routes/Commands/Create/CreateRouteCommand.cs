using Alpinity.Application.UseCases.Routes.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.Create;

// create a new route
// the following is the route entitiy
// public class Route
// {
//     public Guid Id { get; set; }
//     public required string Name { get; set; }
//     public string? Description { get; set; }
//     public string? Grade { get; set; }
//     
//     public Guid SectorId { get; set; }
//     public Sector? Sector { get; set; }
//     
//     public ICollection<RoutePhoto>? RoutePhotos { get; set; }
// }

public class CreateRouteCommand : IRequest<RouteDetailedDto>
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public string? Grade { get; set; }
    public required Guid SectorId { get; set; }
}