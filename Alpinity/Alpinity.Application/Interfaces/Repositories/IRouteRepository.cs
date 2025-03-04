using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IRouteRepository
{
    Task CreateRoute(Route route);

    Task<Route?> GetRouteById(Guid routeId);

    Task<ICollection<Route>> GetRoutesByName(string query, SearchOptionsDto searchOptions);

    Task AddPhoto(Guid routeId, RoutePhoto routePhoto);

    Task<ICollection<Route>> GetRecentlyAscendedRoutes(Guid userId);
}