using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands;

public class DeleteCragCommandHandler(ICragRepository cragRepository, IAuthenticationContext authenticationContext) : IRequestHandler<DeleteCragCommand>
{
    public async Task Handle(DeleteCragCommand request, CancellationToken cancellationToken)
    {
        var exists = await cragRepository.CragExists(request.CragId, cancellationToken);
        if (!exists)
        {
            throw new EntityNotFoundException("Crag not found.");
        }

        var userRole = authenticationContext.GetUserRole();
        if (userRole != UserRole.Admin)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await cragRepository.IsUserCreatorOfCrag(request.CragId, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to delete this crag.");
            }
        }

        await cragRepository.DeleteCrag(request.CragId, cancellationToken);
    }
}