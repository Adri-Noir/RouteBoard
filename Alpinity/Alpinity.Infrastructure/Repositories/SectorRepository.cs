using System.Reflection.Metadata.Ecma335;
using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Alpinity.Infrastructure.Repositories;

public class SectorRepository(ApplicationDbContext dbContext, ICragRepository cragRepository) : ISectorRepository
{
    public async Task CreateSector(Sector sector, CancellationToken cancellationToken = default)
    {
        await dbContext.Sectors.AddAsync(sector, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<bool> SectorExists(Guid sectorId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Sectors.AnyAsync(sector => sector.Id == sectorId, cancellationToken);
    }

    public async Task<Sector?> GetSectorById(Guid sectorId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Sectors
            .Include(sector => sector.Crag)
            .Include(sector => sector.Photos)
            .Include(sector => sector.Routes!)
            .ThenInclude(route => route.RoutePhotos!)
            .ThenInclude(photo => photo.Image)
            .Include(sector => sector.Routes!)
            .ThenInclude(route => route.RoutePhotos!)
            .ThenInclude(photo => photo.PathLine)
            .Include(sector => sector.Routes!)
            .ThenInclude(route => route.Ascents)
            .FirstOrDefaultAsync(sector => sector.Id == sectorId, cancellationToken);
    }

    public async Task<Crag?> GetCragBySectorId(Guid sectorId, CancellationToken cancellationToken = default)
    {
        var cragId = await dbContext.Sectors
            .Where(sector => sector.Id == sectorId)
            .Select(sector => sector.CragId)
            .FirstOrDefaultAsync(cancellationToken);

        if (cragId == default)
        {
            return null;
        }

        return await cragRepository.GetCragById(cragId, cancellationToken);
    }

    public async Task<ICollection<Sector>> GetSectorsByName(string query, SearchOptionsDto searchOptions, CancellationToken cancellationToken = default)
    {
        return await dbContext.Sectors
            .Include(sector => sector.Photos.Take(1))
            .Include(sector => sector.Routes)
            .Where(sector => EF.Functions.ILike(sector.Name, $"%{query}%"))
            .OrderBy(sector => sector.Name)
            // TODO: Implement a better search algorithm method like indexing and ranking instead of alfa ordering
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task AddPhoto(Guid sectorId, Photo sectorPhoto, CancellationToken cancellationToken = default)
    {
        var sector = await dbContext.Sectors
            .Include(sector => sector.Photos)
            .FirstOrDefaultAsync(sector => sector.Id == sectorId, cancellationToken);

        sector!.Photos ??= [];
        sector.Photos.Add(sectorPhoto);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task AddPhotos(Guid sectorId, ICollection<Photo> sectorPhotos, CancellationToken cancellationToken = default)
    {
        var sector = await dbContext.Sectors
            .Include(sector => sector.Photos)
            .FirstOrDefaultAsync(sector => sector.Id == sectorId, cancellationToken);

        sector!.Photos ??= [];
        sectorPhotos.ToList().ForEach(sectorPhoto => sector.Photos.Add(sectorPhoto));

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<ICollection<Sector>> GetSectorsByBoundingBox(Point northEast, Point southWest, CancellationToken cancellationToken = default)
    {
        return await dbContext.Sectors
            .Where(sector => sector.Location != null && sector.Location.X >= southWest.X && sector.Location.X <= northEast.X && sector.Location.Y >= southWest.Y && sector.Location.Y <= northEast.Y)
            .ToListAsync(cancellationToken);
    }

    public async Task<ICollection<Sector>> GetSectorsOnlyByCragId(Guid cragId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Sectors
            .Where(sector => sector.CragId == cragId)
            .Include(sector => sector.Photos)
            .ToListAsync(cancellationToken);
    }

    public async Task UpdateSector(Sector sector, CancellationToken cancellationToken = default)
    {
        dbContext.Sectors.Update(sector);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteSector(Guid sectorId, CancellationToken cancellationToken = default)
    {
        var sector = await dbContext.Sectors.FindAsync(new object[] { sectorId }, cancellationToken);
        if (sector != null)
        {
            dbContext.Sectors.Remove(sector);
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task<bool> IsUserCreatorOfSector(Guid sectorId, Guid userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Sectors
            .AnyAsync(sector => sector.Id == sectorId && sector.Crag!.CragCreators!.Any(creator => creator.UserId == userId), cancellationToken);
    }
}