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
        var userRole = authenticationContext.GetUserRole();
        if (userRole != UserRole.Admin && userRole != UserRole.Creator)
        {
            throw new UnAuthorizedAccessException("You are not authorized to delete a crag.");
        }

        var exists = await cragRepository.CragExists(request.CragId, cancellationToken);
        if (!exists)
        {
            throw new EntityNotFoundException("Crag not found.");
        }

        await cragRepository.DeleteCrag(request.CragId, cancellationToken);
    }
}