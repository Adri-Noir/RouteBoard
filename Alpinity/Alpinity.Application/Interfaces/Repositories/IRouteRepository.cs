using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IRouteRepository
{
    Task CreateRoute(Route route);

    Task<Route?> GetRouteById(Guid routeId);

    Task<IEnumerable<Route>> GetRoutesByName(string query, SearchOptionsDto searchOptions);

    Task AddPhoto(Guid routeId, RoutePhoto routePhoto);
}