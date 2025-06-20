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
            .Include(crag => crag.Sectors)
            .ThenInclude(sector => sector.Routes)
            .Where(crag =>
                EF.Functions.ILike(crag.Name, $"%{query}%") ||
                (crag.LocationName != null && EF.Functions.ILike(crag.LocationName, $"%{query}%")))
            .OrderBy(crag => crag.Name)
            // TODO: Implement a better search algorithm method like indexing and ranking instead of alfa ordering
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task<ICollection<Crag>> GetCragsFromLocation(double latitude, double longitude, double radius, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags
            .Include(crag => crag.Photos.Take(1))
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

    public async Task DeleteCrag(Guid cragId, CancellationToken cancellationToken = default)
    {
        var crag = await dbContext.Crags.FindAsync(new object[] { cragId }, cancellationToken);
        if (crag != null)
        {
            dbContext.Crags.Remove(crag);
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task AddCragCreator(Guid cragId, Guid userId, CancellationToken cancellationToken = default)
    {
        var cragCreator = new CragCreator { CragId = cragId, UserId = userId };
        await dbContext.CragCreators.AddAsync(cragCreator, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<bool> IsUserCreatorOfCrag(Guid cragId, Guid userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.CragCreators
            .AnyAsync(cc => cc.CragId == cragId && cc.UserId == userId, cancellationToken);
    }

    public async Task<Crag?> GetCragForDownload(Guid cragId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Crags
            .Include(crag => crag.Photos)
            .Include(crag => crag.Sectors!)
                .ThenInclude(sector => sector.Photos)
            .Include(crag => crag.Sectors!)
                .ThenInclude(sector => sector.Routes!)
            .Include(crag => crag.Sectors!)
                .ThenInclude(sector => sector.Routes!)
                    .ThenInclude(route => route.RoutePhotos!)
                        .ThenInclude(photo => photo.Image)
            .Include(crag => crag.Sectors!)
                .ThenInclude(sector => sector.Routes!)
                    .ThenInclude(route => route.RoutePhotos!)
                        .ThenInclude(photo => photo.CombinedPhoto)
            .Include(crag => crag.Sectors!)
                .ThenInclude(sector => sector.Routes!)
                    .ThenInclude(route => route.RoutePhotos!)
                        .ThenInclude(photo => photo.PathLine)
            .FirstOrDefaultAsync(crag => crag.Id == cragId, cancellationToken);
    }

    public async Task<ICollection<User>> GetCragCreatorsAsync(Guid cragId, CancellationToken cancellationToken = default)
    {
        return await dbContext.CragCreators
            .Where(cc => cc.CragId == cragId)
            .Include(cc => cc.User)
            .ThenInclude(u => u.ProfilePhoto)
            .Select(cc => cc.User)
            .OrderBy(u => u.Username)
            .ToListAsync(cancellationToken);
    }

    public async Task RemoveCragCreator(Guid cragId, Guid userId, CancellationToken cancellationToken = default)
    {
        var cragCreator = await dbContext.CragCreators
            .FirstOrDefaultAsync(cc => cc.CragId == cragId && cc.UserId == userId, cancellationToken);

        if (cragCreator != null)
        {
            dbContext.CragCreators.Remove(cragCreator);
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }
}