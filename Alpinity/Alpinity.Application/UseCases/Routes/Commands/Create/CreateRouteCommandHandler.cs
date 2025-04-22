using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;
using Alpinity.Application.Interfaces;

namespace Alpinity.Application.UseCases.Routes.Commands.Create;

public class CreateRouteCommandHandler(
    IRouteRepository routeRepository,
    ISectorRepository sectorRepository,
    IMapper mapper,
    IAuthenticationContext authenticationContext) : IRequestHandler<CreateRouteCommand, RouteDetailedDto>
{
    public async Task<RouteDetailedDto> Handle(CreateRouteCommand request, CancellationToken cancellationToken)
    {
        var sectorExists = await sectorRepository.SectorExists(request.SectorId, cancellationToken);
        if (!sectorExists)
        {
            throw new EntityNotFoundException("Sector not found.");
        }

        var userRole = authenticationContext.GetUserRole();
        if (userRole != UserRole.Admin)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await sectorRepository.IsUserCreatorOfSector(request.SectorId, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to create a route for this sector.");
            }
        }

        var route = mapper.Map<Route>(request);
        route.SectorId = request.SectorId;

        await routeRepository.CreateRoute(route, cancellationToken);

        return mapper.Map<RouteDetailedDto>(route);
    }
}