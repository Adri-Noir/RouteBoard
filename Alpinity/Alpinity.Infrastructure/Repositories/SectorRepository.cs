using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class SectorRepository(ApplicationDbContext dbContext) : ISectorRepository
{
    public async Task CreateSector(Sector sector)
    {
        await dbContext.Sectors.AddAsync(sector);
        await dbContext.SaveChangesAsync();
    }
    
    public async Task<Sector?> GetSectorById(Guid sectorId)
    {
        return await dbContext.Sectors.FindAsync(sectorId);
    }

    public async Task<IEnumerable<Sector>> GetSectorsByName(string query, SearchOptionsDto searchOptions)
    {
        return await dbContext.Sectors
            .Where(sector => sector.Name.Contains(query))
            // TODO: Implement a better search algorithm method like indexing
            // .OrderByDescending(sector => EF.Functions.FreeText(sector.Name, query))
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync();
    }
}