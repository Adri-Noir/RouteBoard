using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Routes.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.Get;

public class GetRouteCommandHandler(
    IRouteRepository routeRepository,
    IMapper mapper) : IRequestHandler<GetRouteCommand, RouteDetailedDto>
{
    public async Task<RouteDetailedDto> Handle(GetRouteCommand request, CancellationToken cancellationToken)
    {
        var route = await routeRepository.GetRouteById(request.Id);
        if (route == null)
        {
            throw new EntityNotFoundException("Route not found.");
        }

        return mapper.Map<RouteDetailedDto>(route);
    }
}