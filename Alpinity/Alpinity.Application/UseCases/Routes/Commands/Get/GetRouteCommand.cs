using Alpinity.Application.UseCases.Routes.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.Get;

public class GetRouteCommand : IRequest<RouteDetailedDto>
{
    public required Guid Id { get; set; }
}