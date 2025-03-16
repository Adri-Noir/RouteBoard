using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ISearchHistoryRepository
{
    Task AddSearchHistoryAsync(SearchHistory searchHistory, CancellationToken cancellationToken = default);
    Task<ICollection<SearchHistory>> GetRecentSearchesByUserAsync(Guid searchingUserId, int count = 10, CancellationToken cancellationToken = default);
    Task CleanupOldSearchesAsync(Guid searchingUserId, int keepCount = 10, CancellationToken cancellationToken = default);
}