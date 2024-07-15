using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ICragRepository
{
    Task<Crag?> GetCragById(Guid cragId);
    Task CreateCrag(Crag crag);
}