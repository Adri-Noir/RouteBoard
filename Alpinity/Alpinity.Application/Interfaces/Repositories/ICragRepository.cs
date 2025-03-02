using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ICragRepository
{
    Task<Crag?> GetCragById(Guid cragId);
    Task CreateCrag(Crag crag);
    Task<ICollection<Crag>> GetCragsByName(string query, SearchOptionsDto searchOptions);
}