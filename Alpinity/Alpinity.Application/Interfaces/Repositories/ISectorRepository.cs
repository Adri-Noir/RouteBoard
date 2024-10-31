using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ISectorRepository
{
    Task CreateSector(Sector sector);
    
    Task<Sector?> GetSectorById(Guid sectorId);
    
    Task<IEnumerable<Sector>> GetSectorsByName(string query, SearchOptionsDto searchOptions);
}