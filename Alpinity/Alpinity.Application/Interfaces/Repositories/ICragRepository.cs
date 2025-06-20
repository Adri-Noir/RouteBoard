using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ICragRepository
{
    Task<Crag?> GetCragById(Guid cragId, CancellationToken cancellationToken = default);
    Task<Crag?> GetCragWithSectors(Guid cragId, CancellationToken cancellationToken = default);
    Task<bool> CragExists(Guid cragId, CancellationToken cancellationToken = default);
    Task CreateCrag(Crag crag, CancellationToken cancellationToken = default);
    Task UpdateCrag(Crag crag, CancellationToken cancellationToken = default);
    Task<ICollection<Crag>> GetCragsByName(string query, SearchOptionsDto searchOptions, CancellationToken cancellationToken = default);
    Task<ICollection<Crag>> GetCragsFromLocation(double latitude, double longitude, double radius, CancellationToken cancellationToken = default);
    Task<ICollection<Crag>> GetCragsByBoundingBox(Point northEast, Point southWest, CancellationToken cancellationToken = default);
    Task<Point?> GetCragLocation(Guid cragId, CancellationToken cancellationToken = default);
    Task DeleteCrag(Guid cragId, CancellationToken cancellationToken = default);
    Task<bool> IsUserCreatorOfCrag(Guid cragId, Guid userId, CancellationToken cancellationToken = default);
    Task AddCragCreator(Guid cragId, Guid userId, CancellationToken cancellationToken = default);
    Task<Crag?> GetCragForDownload(Guid cragId, CancellationToken cancellationToken = default);
    Task<ICollection<User>> GetCragCreatorsAsync(Guid cragId, CancellationToken cancellationToken = default);
    Task RemoveCragCreator(Guid cragId, Guid userId, CancellationToken cancellationToken = default);
}