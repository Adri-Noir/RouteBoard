using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class AscentRepository(
    ApplicationDbContext dbContext) : IAscentRepository
{
    public async Task<Ascent> AddAsync(Ascent ascent)
    {
        await dbContext.Ascents.AddAsync(ascent);
        await dbContext.SaveChangesAsync();
        return ascent;
    }

    public async Task<Ascent?> GetByIdAsync(Guid id)
    {
        return await dbContext.Ascents
            .Include(a => a.User)
            .Include(a => a.Route)
            .FirstOrDefaultAsync(a => a.Id == id);
    }

    public async Task<IEnumerable<Ascent>> GetByUserIdAsync(Guid userId)
    {
        return await dbContext.Ascents
            .Include(a => a.Route)
            .Where(a => a.UserId == userId)
            .ToListAsync();
    }

    public async Task<IEnumerable<Ascent>> GetByRouteIdAsync(Guid routeId)
    {
        return await dbContext.Ascents
            .Include(a => a.User)
            .Where(a => a.RouteId == routeId)
            .ToListAsync();
    }

    public async Task<Ascent> UpdateAsync(Ascent ascent)
    {
        dbContext.Ascents.Update(ascent);
        await dbContext.SaveChangesAsync();
        return ascent;
    }

    public async Task DeleteAsync(Guid id)
    {
        var ascent = await dbContext.Ascents.FindAsync(id);
        if (ascent != null)
        {
            dbContext.Ascents.Remove(ascent);
            await dbContext.SaveChangesAsync();
        }
    }
} 