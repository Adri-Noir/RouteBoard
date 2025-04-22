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
        var exists = await sectorRepository.SectorExists(request.SectorId, cancellationToken);
        if (!exists)
        {
            throw new EntityNotFoundException("Sector not found.");
        }

        var sector = await sectorRepository.GetSectorById(request.SectorId, cancellationToken)
            ?? throw new EntityNotFoundException("Sector not found.");
        var cragId = sector.CragId;

        var userRole = authenticationContext.GetUserRole();
        if (userRole != UserRole.Admin)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await sectorRepository.IsUserCreatorOfSector(request.SectorId, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to delete this sector.");
            }
        }

        await sectorRepository.DeleteSector(request.SectorId, cancellationToken);

        var crag = await cragRepository.GetCragWithSectors(cragId, cancellationToken)
            ?? throw new EntityNotFoundException("Crag not found.");
        crag.Location = LocationCalculationHelper.CalculateAverageLocation(crag.Sectors);
        await cragRepository.UpdateCrag(crag, cancellationToken);
    }
}