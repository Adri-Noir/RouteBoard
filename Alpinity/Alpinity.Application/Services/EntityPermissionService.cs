using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Domain.Enums;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Alpinity.Application.Services;

public class EntityPermissionService(
    IAuthenticationContext authContext,
    ICragRepository cragRepository,
    ISectorRepository sectorRepository,
    IRouteRepository routeRepository
) : IEntityPermissionService
{
    public async Task<bool> CanModifyCrag(Guid cragId, CancellationToken cancellationToken = default)
    {
        var role = authContext.GetUserRole();
        var userId = authContext.GetUserId();
        if (role == UserRole.Admin) return true;
        if (userId.HasValue)
            return await cragRepository.IsUserCreatorOfCrag(cragId, userId.Value, cancellationToken);
        return false;
    }

    public async Task<bool> CanModifySector(Guid sectorId, CancellationToken cancellationToken = default)
    {
        var role = authContext.GetUserRole();
        var userId = authContext.GetUserId();
        if (role == UserRole.Admin) return true;
        if (userId.HasValue)
            return await sectorRepository.IsUserCreatorOfSector(sectorId, userId.Value, cancellationToken);
        return false;
    }

    public async Task<bool> CanModifyRoute(Guid routeId, CancellationToken cancellationToken = default)
    {
        var role = authContext.GetUserRole();
        var userId = authContext.GetUserId();
        if (role == UserRole.Admin) return true;
        if (userId.HasValue)
            return await routeRepository.IsUserCreatorOfRoute(routeId, userId.Value, cancellationToken);
        return false;
    }
}