using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Enums;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.Create;

public class CreateRouteCommand : IRequest<RouteDetailedDto>
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public ClimbingGrade? Grade { get; set; }
    public ICollection<RouteType>? RouteType { get; set; }
    public int? Length { get; set; }
    public required Guid SectorId { get; set; }
}