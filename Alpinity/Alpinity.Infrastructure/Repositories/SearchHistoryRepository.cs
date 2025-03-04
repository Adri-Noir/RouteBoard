using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class SearchHistoryRepository : ISearchHistoryRepository
{
    private readonly ApplicationDbContext _context;

    public SearchHistoryRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task AddSearchHistoryAsync(SearchHistory searchHistory)
    {
        await _context.SearchHistories.AddAsync(searchHistory);

        await _context.SaveChangesAsync();

        // Cleanup old searches to keep only the most recent ones
        await CleanupOldSearchesAsync(searchHistory.SearchingUserId);

        await _context.SaveChangesAsync();
    }

    public async Task<ICollection<SearchHistory>> GetRecentSearchesByUserAsync(Guid searchingUserId, int count = 10)
    {
        return await _context.SearchHistories
            // Include Crag data
            .Include(sh => sh.Crag)
            .ThenInclude(c => c.Sectors!)
            .ThenInclude(s => s.Routes!)

            // Include Sector data with its Crag
            .Include(sh => sh.Sector)
            .ThenInclude(s => s.Crag)
            .ThenInclude(c => c.Sectors!)

            // Include Route data with its Sector and the Sector's Crag
            .Include(sh => sh.Route)
            .ThenInclude(r => r.Sector!)
            .ThenInclude(s => s.Crag)
            .Include(sh => sh.Route)
            .ThenInclude(r => r.Ascents!)

            // Include User profile data
            .Include(sh => sh.ProfileUser)

            // Filter by the searching user
            .Where(sh => sh.SearchingUserId == searchingUserId)
            .OrderByDescending(sh => sh.SearchedAt)
            .Take(count)
            .ToListAsync();
    }

    public async Task CleanupOldSearchesAsync(Guid searchingUserId, int keepCount = 10)
    {
        var userSearchHistories = await _context.SearchHistories
            .Where(sh => sh.SearchingUserId == searchingUserId)
            .OrderByDescending(sh => sh.SearchedAt)
            .ToListAsync();

        var processedEntities = new HashSet<string>();
        var toKeep = new List<SearchHistory>();
        var toRemove = new List<SearchHistory>();

        foreach (var entry in userSearchHistories)
        {
            var entityKey = GetEntityKey(entry);
            if (!processedEntities.Contains(entityKey))
            {
                processedEntities.Add(entityKey);
                toKeep.Add(entry);
                if (toKeep.Count >= keepCount)
                    break;
            }
            else
            {
                toRemove.Add(entry);
            }
        }

        if (toKeep.Count < userSearchHistories.Count)
            toRemove.AddRange(userSearchHistories.Skip(toKeep.Count + toRemove.Count));

        if (toRemove.Any()) _context.SearchHistories.RemoveRange(toRemove);
    }

    public async Task<ICollection<SearchHistory>> GetRecentSearchesAsync(int count = 10)
    {
        return await _context.SearchHistories
            .OrderByDescending(sh => sh.SearchedAt)
            .Take(count)
            .ToListAsync();
    }

    private string GetEntityKey(SearchHistory searchHistory)
    {
        if (searchHistory.RouteId.HasValue)
            return $"Route_{searchHistory.RouteId}";
        if (searchHistory.SectorId.HasValue)
            return $"Sector_{searchHistory.SectorId}";
        if (searchHistory.CragId.HasValue)
            return $"Crag_{searchHistory.CragId}";
        if (searchHistory.ProfileUserId.HasValue)
            return $"User_{searchHistory.ProfileUserId}";

        return $"Unknown_{searchHistory.Id}";
    }
}