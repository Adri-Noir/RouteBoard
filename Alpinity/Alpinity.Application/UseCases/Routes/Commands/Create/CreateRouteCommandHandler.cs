using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.Create;

public class CreateRouteCommandHandler(
    IRouteRepository routeRepository,
    ISectorRepository sectorRepository,
    IMapper mapper) : IRequestHandler<CreateRouteCommand, RouteDetailedDto>
{
    public async Task<RouteDetailedDto> Handle(CreateRouteCommand request, CancellationToken cancellationToken)
    {
        var sector = await sectorRepository.GetSectorById(request.SectorId);
        if (sector == null) throw new EntityNotFoundException("Sector not found.");

        var route = mapper.Map<Route>(request);
        route.SectorId = request.SectorId;

        await routeRepository.CreateRoute(route);

        return mapper.Map<RouteDetailedDto>(route);
    }
}