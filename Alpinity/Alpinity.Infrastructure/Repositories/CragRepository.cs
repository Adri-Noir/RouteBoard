using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class CragRepository(ApplicationDbContext dbContext) : ICragRepository
{
    public async Task<Crag?> GetCragById(Guid cragId)
    {
        return await dbContext.Crags.FirstOrDefaultAsync(crag => crag.Id == cragId);
    }
    
    public async Task CreateCrag(Crag crag)
    {
        await dbContext.Crags.AddAsync(crag);
        await dbContext.SaveChangesAsync();
    }
}