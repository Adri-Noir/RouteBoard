using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ISectorRepository
{
    Task CreateSector(Sector sector, CancellationToken cancellationToken = default);

    Task<Sector?> GetSectorById(Guid sectorId, CancellationToken cancellationToken = default);

    Task<Crag?> GetCragBySectorId(Guid sectorId, CancellationToken cancellationToken = default);

    Task<ICollection<Sector>> GetSectorsByName(string query, SearchOptionsDto searchOptions, CancellationToken cancellationToken = default);

    Task AddPhoto(Guid sectorId, Photo sectorPhoto, CancellationToken cancellationToken = default);

    Task AddPhotos(Guid sectorId, ICollection<Photo> sectorPhotos, CancellationToken cancellationToken = default);

    Task<ICollection<Sector>> GetSectorsByBoundingBox(Point northEast, Point southWest, CancellationToken cancellationToken = default);

    Task<ICollection<Sector>> GetSectorsOnlyByCragId(Guid cragId, CancellationToken cancellationToken = default);
}