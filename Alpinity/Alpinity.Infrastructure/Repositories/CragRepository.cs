using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Alpinity.Infrastructure.Repositories;

public class CragRepository(ApplicationDbContext dbContext) : ICragRepository
{
    public async Task<Crag?> GetCragById(Guid cragId)
    {
        return await dbContext.Crags
            .Include(crag => crag.Sectors!)
            .ThenInclude(sector => sector.Routes!)
            .Include(crag => crag.Sectors!.OrderBy(sector => sector.Name))
            .ThenInclude(sector => sector.Photos)
            .FirstOrDefaultAsync(crag => crag.Id == cragId);
    }

    public async Task CreateCrag(Crag crag)
    {
        await dbContext.Crags.AddAsync(crag);
        await dbContext.SaveChangesAsync();
    }

    public async Task<ICollection<Crag>> GetCragsByName(string query, SearchOptionsDto searchOptions)
    {
        return await dbContext.Crags
            .Where(crag => crag.Name.Contains(query))
            // TODO: Implement a better search algorithm method like indexing
            // .OrderByDescending(crag => EF.Functions.FreeText(crag.Name, query))
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync();
    }

    public async Task<ICollection<Crag>> GetCragsFromLocation(double latitude, double longitude, double radius)
    {
        return await dbContext.Crags
            .Where(crag => crag.Location != null && crag.Location.Distance(new Point(longitude, latitude) { SRID = 4326 }) <= radius)
            .OrderBy(crag => crag.Location != null ? crag.Location.Distance(new Point(longitude, latitude) { SRID = 4326 }) : 0)
            .ToListAsync();
    }
}