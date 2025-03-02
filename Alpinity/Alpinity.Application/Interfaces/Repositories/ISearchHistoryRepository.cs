using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ISearchHistoryRepository
{
    Task AddSearchHistoryAsync(SearchHistory searchHistory);
    Task<ICollection<SearchHistory>> GetRecentSearchesByUserAsync(Guid searchingUserId, int count = 10);
    Task CleanupOldSearchesAsync(Guid searchingUserId, int keepCount = 10);
} 