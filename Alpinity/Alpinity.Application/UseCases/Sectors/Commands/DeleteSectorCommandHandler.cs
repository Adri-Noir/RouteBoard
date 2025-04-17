using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Commands;

public class DeleteSectorCommandHandler(ISectorRepository sectorRepository, IAuthenticationContext authenticationContext) : IRequestHandler<DeleteSectorCommand>
{
    public async Task Handle(DeleteSectorCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();
        if (userRole != UserRole.Admin && userRole != UserRole.Creator)
        {
            throw new UnAuthorizedAccessException("You are not authorized to delete a sector.");
        }

        var exists = await sectorRepository.SectorExists(request.SectorId, cancellationToken);
        if (!exists)
        {
            throw new EntityNotFoundException("Sector not found.");
        }

        await sectorRepository.DeleteSector(request.SectorId, cancellationToken);
    }
}