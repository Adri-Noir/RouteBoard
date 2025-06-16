using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class RouteRepository(ApplicationDbContext dbContext) : IRouteRepository
{
    public async Task CreateRoute(Route route, CancellationToken cancellationToken = default)
    {
        await dbContext.Routes.AddAsync(route, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateRoute(Route route, CancellationToken cancellationToken = default)
    {
        dbContext.Routes.Update(route);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<Route?> GetRouteById(Guid routeId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Routes
            .Include(route => route.Sector)
            .Include(route => route.Sector!.Crag)
            .Include(route => route.RoutePhotos!)
            .ThenInclude(photo => photo.Image)
            .Include(route => route.RoutePhotos!)
            .ThenInclude(photo => photo.PathLine)
            .Include(route => route.RoutePhotos!)
            .ThenInclude(photo => photo.CombinedPhoto)
            .Include(route => route.Ascents!.OrderByDescending(ascent => ascent.AscentDate))
            // TODO: on ios app we should move to using the ascent repository instead of relying on the route repository
            .ThenInclude(ascent => ascent.User)
            .ThenInclude(user => user.ProfilePhoto)
            .FirstOrDefaultAsync(route => route.Id == routeId, cancellationToken);
    }

    public async Task<bool> RouteExists(Guid routeId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Routes.AnyAsync(r => r.Id == routeId, cancellationToken);
    }

    public async Task<ICollection<Route>> GetRoutesByName(string query, SearchOptionsDto searchOptions, CancellationToken cancellationToken = default)
    {
        return await dbContext.Routes
            .Include(route => route.RoutePhotos!.Take(1))
            .ThenInclude(photo => photo.CombinedPhoto)
            .Include(route => route.Ascents!)
            .Include(route => route.Sector)
            .Where(route => EF.Functions.ILike(route.Name, $"%{query}%"))
            .OrderBy(route => route.Name)
            // TODO: Implement a better search algorithm method like indexing and ranking instead of alfa ordering
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task AddPhoto(Guid routeId, RoutePhoto routePhoto, CancellationToken cancellationToken = default)
    {
        var route = await dbContext.Routes
            .Include(route => route.RoutePhotos)
            .FirstOrDefaultAsync(route => route.Id == routeId, cancellationToken);

        route!.RoutePhotos ??= [];
        route.RoutePhotos.Add(routePhoto);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<ICollection<Route>> GetRecentlyAscendedRoutes(Guid userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Ascents
            .Where(ascent => ascent.UserId == userId)
            .OrderByDescending(ascent => ascent.AscentDate)
            .Include(ascent => ascent.Route!.Sector)
            .Include(ascent => ascent.Route!.Sector!.Crag)
            .Include(ascent => ascent.Route!.RoutePhotos!)
                .ThenInclude(photo => photo.Image)
            .Include(ascent => ascent.Route!.RoutePhotos!)
                .ThenInclude(photo => photo.PathLine)
            .Include(ascent => ascent.Route!.RoutePhotos!)
                .ThenInclude(photo => photo.CombinedPhoto)
            .Include(ascent => ascent.Route!.Ascents!)
            .Where(ascent => ascent.Route != null)
            .Select(ascent => ascent.Route!)
            .Distinct()
            .Take(10)
            .ToListAsync(cancellationToken);
    }

    public async Task<ICollection<RoutePhoto>> GetRoutePhotos(Guid routeId, CancellationToken cancellationToken = default)
    {
        return await dbContext.RoutePhotos
            .Where(rp => rp.RouteId == routeId)
            .Include(rp => rp.Image)
            .Include(rp => rp.PathLine)
            .Include(rp => rp.CombinedPhoto)
            .ToListAsync(cancellationToken);
    }

    public async Task DeleteRoute(Guid routeId, CancellationToken cancellationToken = default)
    {
        var route = await dbContext.Routes.FindAsync(new object[] { routeId }, cancellationToken);
        if (route != null)
        {
            dbContext.Routes.Remove(route);
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task<bool> IsUserCreatorOfRoute(Guid routeId, Guid userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Routes
            .AnyAsync(route => route.Id == routeId && route.Sector!.Crag!.CragCreators!.Any(creator => creator.UserId == userId), cancellationToken);
    }

    public async Task<Route?> GetRouteForDownload(Guid routeId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Routes
            .Include(route => route.Sector)
            .Include(route => route.Sector!.Crag)
            .Include(route => route.RoutePhotos!)
                .ThenInclude(photo => photo.Image)
            .Include(route => route.RoutePhotos!)
                .ThenInclude(photo => photo.PathLine)
            .Include(route => route.RoutePhotos!)
                .ThenInclude(photo => photo.CombinedPhoto)
            .FirstOrDefaultAsync(route => route.Id == routeId, cancellationToken);
    }
}