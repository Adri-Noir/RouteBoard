using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.UseCases.Sectors.Commands.Create;

public class CreateSectorCommandHandler(
    ISectorRepository sectorRepository,
    ICragRepository cragRepository,
    IMapper mapper) : IRequestHandler<CreateSectorCommand, SectorDetailedDto>
{
    public async Task<SectorDetailedDto> Handle(CreateSectorCommand request, CancellationToken cancellationToken)
    {
        var cragExists = await cragRepository.CragExists(request.CragId, cancellationToken);
        if (!cragExists) throw new EntityNotFoundException("Crag not found.");

        var point = mapper.Map<Point>(request.Location);

        var sector = new Sector
        {
            Name = request.Name,
            Description = request.Description,
            CragId = request.CragId,
            Location = point
        };

        await sectorRepository.CreateSector(sector, cancellationToken);

        return mapper.Map<SectorDetailedDto>(sector);
    }
}