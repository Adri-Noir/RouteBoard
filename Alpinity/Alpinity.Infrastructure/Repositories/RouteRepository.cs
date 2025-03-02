using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class RouteRepository(ApplicationDbContext dbContext) : IRouteRepository
{
    public async Task CreateRoute(Route route)
    {
        await dbContext.Routes.AddAsync(route);
        await dbContext.SaveChangesAsync();
    }

    public async Task<Route?> GetRouteById(Guid routeId)
    {
        return await dbContext.Routes
            .Include(route => route.Sector)
            .Include("Sector.Crag")
            .Include(route => route.RoutePhotos)
            .Include("RoutePhotos.Image")
            .Include("RoutePhotos.PathLine")
            .Include(route => route.Ascents!.OrderByDescending(ascent => ascent.AscentDate))
            .ThenInclude(ascent => ascent.User)
            .FirstOrDefaultAsync(route => route.Id == routeId);
    }

    public async Task<ICollection<Route>> GetRoutesByName(string query, SearchOptionsDto searchOptions)
    {
        return await dbContext.Routes
            .Where(route => route.Name.Contains(query))
            // TODO: Implement a better search algorithm method like indexing
            // .OrderByDescending(route => EF.Functions.FreeText(route.Name, query))
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync();
    }

    public async Task AddPhoto(Guid routeId, RoutePhoto routePhoto)
    {
        var route = await dbContext.Routes
            .Include(route => route.RoutePhotos)
            .FirstOrDefaultAsync(route => route.Id == routeId);

        route!.RoutePhotos ??= [];
        route.RoutePhotos.Add(routePhoto);
        await dbContext.SaveChangesAsync();
    }

    public async Task<ICollection<Route?>> GetRecentlyAscendedRoutes(Guid userId)
    {
        return await dbContext.Ascents
            .Where(ascent => ascent.UserId == userId)
            .OrderByDescending(ascent => ascent.AscentDate)
            .Take(10)
            .Include(ascent => ascent.Route!.Sector)
            .Include(ascent => ascent.Route!.Sector!.Crag)
            .Select(ascent => ascent.Route)
            .Distinct()
            .ToListAsync();
    }
    
}