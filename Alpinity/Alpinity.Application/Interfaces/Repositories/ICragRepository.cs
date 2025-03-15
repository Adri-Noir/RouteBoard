using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ICragRepository
{
    Task<Crag?> GetCragById(Guid cragId);
    Task CreateCrag(Crag crag);
    Task<ICollection<Crag>> GetCragsByName(string query, SearchOptionsDto searchOptions);
    Task<ICollection<Crag>> GetCragsFromLocation(double latitude, double longitude, double radius);
    Task<ICollection<Crag>> GetCragsByBoundingBox(Point northEast, Point southWest, CancellationToken cancellationToken);

    Task<bool> CragExists(Guid cragId, CancellationToken cancellationToken);
}