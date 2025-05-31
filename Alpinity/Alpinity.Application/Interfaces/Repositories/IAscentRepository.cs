using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IAscentRepository
{
    Task<Ascent> AddAsync(Ascent ascent, CancellationToken cancellationToken = default);
    Task<Ascent?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<ICollection<Ascent>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<ICollection<Ascent>> GetByRouteIdAsync(Guid routeId, CancellationToken cancellationToken = default);
    Task<Ascent> UpdateAsync(Ascent ascent, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    Task<(ICollection<Ascent> Ascents, int TotalCount)> GetPaginatedByUserIdAsync(Guid userId, int page, int pageSize, CancellationToken cancellationToken = default);
}