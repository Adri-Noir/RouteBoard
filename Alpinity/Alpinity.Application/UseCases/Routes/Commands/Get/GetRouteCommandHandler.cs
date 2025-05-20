using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.Get;

public class GetRouteCommandHandler(
    IRouteRepository routeRepository,
    ISearchHistoryRepository searchHistoryRepository,
    IAuthenticationContext authenticationContext,
    IMapper mapper,
    IEntityPermissionService permissionService) : IRequestHandler<GetRouteCommand, RouteDetailedDto>
{
    public async Task<RouteDetailedDto> Handle(GetRouteCommand request, CancellationToken cancellationToken)
    {
        var route = await routeRepository.GetRouteById(request.Id, cancellationToken) ?? throw new EntityNotFoundException("Route not found.");

        // Save search history if user is authenticated
        var userId = authenticationContext.GetUserId();
        if (userId.HasValue)
        {
            var searchHistory = new Domain.Entities.SearchHistory
            {
                Id = Guid.NewGuid(),
                EntityType = SearchResultItemType.Route,
                RouteId = route.Id,
                Route = route,
                SearchingUserId = userId.Value,
                SearchedAt = DateTime.UtcNow
            };

            await searchHistoryRepository.AddSearchHistoryAsync(searchHistory, cancellationToken);
        }

        var dto = mapper.Map<RouteDetailedDto>(route);
        dto.CanModify = await permissionService.CanModifyRoute(route.Id, cancellationToken);
        return dto;
    }
}