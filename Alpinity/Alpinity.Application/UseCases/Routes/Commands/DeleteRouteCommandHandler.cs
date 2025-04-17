using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands;

public class DeleteRouteCommandHandler(IRouteRepository routeRepository, IAuthenticationContext authenticationContext) : IRequestHandler<DeleteRouteCommand>
{
    public async Task Handle(DeleteRouteCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();
        if (userRole != UserRole.Admin && userRole != UserRole.Creator)
        {
            throw new UnAuthorizedAccessException("You are not authorized to delete a route.");
        }

        var exists = await routeRepository.RouteExists(request.RouteId, cancellationToken);
        if (!exists)
        {
            throw new EntityNotFoundException("Route not found.");
        }

        await routeRepository.DeleteRoute(request.RouteId, cancellationToken);
    }
}