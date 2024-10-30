using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Constants.Search;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class RouteRepository(ApplicationDbContext dbContext) : IRouteRepository
{
    public Task CreateRoute(Route route)
    {
        throw new NotImplementedException();
    }

    public async Task<Route?> GetRouteById(Guid routeId)
    {
        return await dbContext.Routes.FindAsync(routeId);
    }

    public async Task<IEnumerable<Route>> GetRoutesByName(string query, SearchOptionsDto searchOptions)
    {
        return await dbContext.Routes
            .Where(route => route.Name.Contains(query))
            // TODO: Implement a better search algorithm method like indexing
            // .OrderByDescending(route => EF.Functions.FreeText(route.Name, query))
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync();
    }
}