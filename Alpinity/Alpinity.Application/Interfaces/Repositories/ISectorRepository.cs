using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ISectorRepository
{
    Task CreateSector(Sector sector);

    Task<Sector?> GetSectorById(Guid sectorId);

    Task<Crag?> GetCragBySectorId(Guid sectorId);

    Task<ICollection<Sector>> GetSectorsByName(string query, SearchOptionsDto searchOptions);

    Task AddPhoto(Guid sectorId, Photo sectorPhoto);

    Task AddPhotos(Guid sectorId, ICollection<Photo> sectorPhotos);
}