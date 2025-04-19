using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using MediatR;
using Alpinity.Application.Helpers;

namespace Alpinity.Application.UseCases.Sectors.Commands;

public class DeleteSectorCommandHandler(ISectorRepository sectorRepository, IAuthenticationContext authenticationContext, ICragRepository cragRepository) : IRequestHandler<DeleteSectorCommand>
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

        var sector = await sectorRepository.GetSectorById(request.SectorId, cancellationToken)
            ?? throw new EntityNotFoundException("Sector not found.");
        var cragId = sector.CragId;

        await sectorRepository.DeleteSector(request.SectorId, cancellationToken);

        var crag = await cragRepository.GetCragWithSectors(cragId, cancellationToken)
            ?? throw new EntityNotFoundException("Crag not found.");
        crag.Location = LocationCalculationHelper.CalculateAverageLocation(crag.Sectors);
        await cragRepository.UpdateCrag(crag, cancellationToken);
    }
}