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

        var exists = await routeRepository.RouteExists(request.RouteId, cancellationToken);
        if (!exists)
        {
            throw new EntityNotFoundException("Route not found.");
        }

        if (userRole != UserRole.Admin)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await routeRepository.IsUserCreatorOfRoute(request.RouteId, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to delete this route.");
            }
        }

        await routeRepository.DeleteRoute(request.RouteId, cancellationToken);
    }
}