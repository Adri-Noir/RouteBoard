using Alpinity.Application.UseCases.Routes.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.Create;

public class CreateRouteCommand : IRequest<RouteDetailedDto>
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public string? Grade { get; set; }
    public required Guid SectorId { get; set; }
}