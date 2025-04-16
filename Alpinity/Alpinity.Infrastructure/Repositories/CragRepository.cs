using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Alpinity.Infrastructure.Repositories;

public class CragRepository(ApplicationDbContext dbContext) : ICragRepository
{
    public async Task<Crag?> GetCragById(Guid cragId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags
            .Include(crag => crag.Photos)
            .Include(crag => crag.Sectors!)
            .ThenInclude(sector => sector.Routes!)
            .ThenInclude(route => route.Ascents!)
            .Include(crag => crag.Sectors!)
            .ThenInclude(sector => sector.Routes!)
            .ThenInclude(route => route.RoutePhotos!)
            .ThenInclude(photo => photo.CombinedPhoto)
            .Include(crag => crag.Sectors!.OrderBy(sector => sector.Name))
            .ThenInclude(sector => sector.Photos)
            .FirstOrDefaultAsync(crag => crag.Id == cragId, cancellationToken);
    }

    public async Task<Crag?> GetCragWithSectors(Guid cragId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags
            .Include(crag => crag.Sectors!.OrderBy(sector => sector.Name))
            .FirstOrDefaultAsync(crag => crag.Id == cragId, cancellationToken);
    }

    public async Task<bool> CragExists(Guid cragId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags.AnyAsync(crag => crag.Id == cragId, cancellationToken);
    }

    public async Task CreateCrag(Crag crag, CancellationToken cancellationToken = default)
    {
        await dbContext.Crags.AddAsync(crag, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<ICollection<Crag>> GetCragsByName(string query, SearchOptionsDto searchOptions, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags
            .Include(crag => crag.Photos.Take(1))
            .Where(crag => EF.Functions.ILike(crag.Name, $"%{query}%"))
            // TODO: Implement a better search algorithm method like indexing
            // .OrderByDescending(crag => EF.Functions.FreeText(crag.Name, query))
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task<ICollection<Crag>> GetCragsFromLocation(double latitude, double longitude, double radius, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags
            .Where(crag => crag.Location != null && crag.Location.Distance(new Point(longitude, latitude) { SRID = 4326 }) <= radius)
            .OrderBy(crag => crag.Location != null ? crag.Location.Distance(new Point(longitude, latitude) { SRID = 4326 }) : 0)
            .ToListAsync(cancellationToken);
    }

    public async Task<ICollection<Crag>> GetCragsByBoundingBox(Point northEast, Point southWest, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags
            .Where(crag => crag.Location != null && crag.Location.X >= southWest.X && crag.Location.X <= northEast.X && crag.Location.Y >= southWest.Y && crag.Location.Y <= northEast.Y)
            .ToListAsync(cancellationToken);
    }

    public async Task<Point?> GetCragLocation(Guid cragId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags
            .Where(crag => crag.Id == cragId)
            .Select(crag => crag.Location)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task UpdateCrag(Crag crag, CancellationToken cancellationToken = default)
    {
        dbContext.Crags.Update(crag);
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}