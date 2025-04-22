using System;
using System.Threading;
using System.Threading.Tasks;

namespace Alpinity.Application.Interfaces.Services;

public interface IEntityPermissionService
{
    Task<bool> CanModifyCrag(Guid cragId, CancellationToken cancellationToken = default);
    Task<bool> CanModifySector(Guid sectorId, CancellationToken cancellationToken = default);
    Task<bool> CanModifyRoute(Guid routeId, CancellationToken cancellationToken = default);
}