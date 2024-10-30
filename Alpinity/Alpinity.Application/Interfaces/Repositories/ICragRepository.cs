using Alpinity.Application.Dtos;
using Alpinity.Domain.Constants.Search;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ICragRepository
{
    Task<Crag?> GetCragById(Guid cragId);
    Task CreateCrag(Crag crag);
    Task<IEnumerable<Crag>> GetCragsByName(string query, SearchOptionsDto searchOptions);
}