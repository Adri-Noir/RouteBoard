using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class AscentRepository(
    ApplicationDbContext dbContext) : IAscentRepository
{
    public async Task<Ascent> AddAsync(Ascent ascent, CancellationToken cancellationToken = default)
    {
        await dbContext.Ascents.AddAsync(ascent, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
        return ascent;
    }

    public async Task<Ascent?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await dbContext.Ascents
            .Include(a => a.User)
            .Include(a => a.Route)
            .FirstOrDefaultAsync(a => a.Id == id, cancellationToken);
    }

    public async Task<ICollection<Ascent>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Ascents
            .Include(a => a.Route)
            .Include(a => a.Route!.Sector)
            .Include(a => a.Route!.Sector!.Crag)
            .Where(a => a.UserId == userId)
            .ToListAsync(cancellationToken);
    }

    public async Task<ICollection<Ascent>> GetByRouteIdAsync(Guid routeId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Ascents
            .Include(a => a.User)
            .Where(a => a.RouteId == routeId)
            .ToListAsync(cancellationToken);
    }

    public async Task<Ascent> UpdateAsync(Ascent ascent, CancellationToken cancellationToken = default)
    {
        dbContext.Ascents.Update(ascent);
        await dbContext.SaveChangesAsync(cancellationToken);
        return ascent;
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var ascent = await dbContext.Ascents.FindAsync(new object[] { id }, cancellationToken: cancellationToken);
        if (ascent != null)
        {
            dbContext.Ascents.Remove(ascent);
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task<(ICollection<Ascent> Ascents, int TotalCount)> GetPaginatedByUserIdAsync(Guid userId, int page, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Ascents
            .Include(a => a.Route)
            .Include(a => a.Route!.Sector)
            .Include(a => a.Route!.Sector!.Crag)
            .Where(a => a.UserId == userId);

        var totalCount = await query.CountAsync(cancellationToken);

        var ascents = await query
            .OrderByDescending(a => a.AscentDate)
            .Skip(page * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (ascents, totalCount);
    }
}