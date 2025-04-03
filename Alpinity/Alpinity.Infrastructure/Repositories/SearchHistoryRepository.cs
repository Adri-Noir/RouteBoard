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

    public async Task AddSearchHistoryAsync(SearchHistory searchHistory, CancellationToken cancellationToken = default)
    {
        await _context.SearchHistories.AddAsync(searchHistory, cancellationToken);

        await _context.SaveChangesAsync(cancellationToken);

        // Cleanup old searches to keep only the most recent ones
        await CleanupOldSearchesAsync(searchHistory.SearchingUserId, 10, cancellationToken);

        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task<ICollection<SearchHistory>> GetRecentSearchesByUserAsync(Guid searchingUserId, int count = 10, CancellationToken cancellationToken = default)
    {
        return await _context.SearchHistories
            // Include Crag data
            .Include(sh => sh.Crag)
            .ThenInclude(c => c.Sectors!)
            .ThenInclude(s => s.Routes!)
            .Include(sh => sh.Crag)
            .ThenInclude(c => c.Photos.Take(1))

            // Include Sector data with its Crag
            .Include(sh => sh.Sector)
            .ThenInclude(s => s.Crag)
            .ThenInclude(c => c.Sectors!)
            .ThenInclude(s => s.Photos.Take(1))

            // Include Route data with its Sector and the Sector's Crag
            .Include(sh => sh.Route)
            .ThenInclude(r => r.Sector!)
            .ThenInclude(s => s.Crag)
            .ThenInclude(c => c.Sectors!)
            .ThenInclude(s => s.Routes!)
            .ThenInclude(r => r.RoutePhotos!.Take(1))
            .ThenInclude(p => p.CombinedPhoto)
            .Include(sh => sh.Route)
            .ThenInclude(r => r.Ascents!)

            // Include User profile data
            .Include(sh => sh.ProfileUser)
            .ThenInclude(u => u.ProfilePhoto)
            // Filter by the searching user
            .Where(sh => sh.SearchingUserId == searchingUserId)
            .OrderByDescending(sh => sh.SearchedAt)
            .Take(count)
            .ToListAsync(cancellationToken);
    }

    public async Task CleanupOldSearchesAsync(Guid searchingUserId, int keepCount = 10, CancellationToken cancellationToken = default)
    {
        var userSearchHistories = await _context.SearchHistories
            .Where(sh => sh.SearchingUserId == searchingUserId)
            .OrderByDescending(sh => sh.SearchedAt)
            .ToListAsync(cancellationToken);

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

    public async Task<ICollection<SearchHistory>> GetRecentSearchesAsync(int count = 10, CancellationToken cancellationToken = default)
    {
        return await _context.SearchHistories
            .OrderByDescending(sh => sh.SearchedAt)
            .Take(count)
            .ToListAsync(cancellationToken);
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