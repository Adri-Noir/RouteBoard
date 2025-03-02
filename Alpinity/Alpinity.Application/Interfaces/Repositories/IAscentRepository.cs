using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IAscentRepository
{
    Task<Ascent> AddAsync(Ascent ascent);
    Task<Ascent?> GetByIdAsync(Guid id);
    Task<ICollection<Ascent>> GetByUserIdAsync(Guid userId);
    Task<ICollection<Ascent>> GetByRouteIdAsync(Guid routeId);
    Task<Ascent> UpdateAsync(Ascent ascent);
    Task DeleteAsync(Guid id);
} 