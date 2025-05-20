using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IRouteRepository
{
    Task CreateRoute(Route route, CancellationToken cancellationToken = default);
    Task UpdateRoute(Route route, CancellationToken cancellationToken = default);

    Task<Route?> GetRouteById(Guid routeId, CancellationToken cancellationToken = default);

    Task<bool> RouteExists(Guid routeId, CancellationToken cancellationToken = default);

    Task<ICollection<Route>> GetRoutesByName(string query, SearchOptionsDto searchOptions, CancellationToken cancellationToken = default);

    Task AddPhoto(Guid routeId, RoutePhoto routePhoto, CancellationToken cancellationToken = default);

    Task<ICollection<Route>> GetRecentlyAscendedRoutes(Guid userId, CancellationToken cancellationToken = default);

    Task<ICollection<RoutePhoto>> GetRoutePhotos(Guid routeId, CancellationToken cancellationToken = default);

    Task DeleteRoute(Guid routeId, CancellationToken cancellationToken = default);

    Task<bool> IsUserCreatorOfRoute(Guid routeId, Guid userId, CancellationToken cancellationToken = default);

    Task<Route?> GetRouteForDownload(Guid routeId, CancellationToken cancellationToken = default);
}