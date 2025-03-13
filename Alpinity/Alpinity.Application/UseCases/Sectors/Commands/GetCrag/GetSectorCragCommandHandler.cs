
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Crags.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Commands.GetCrag;

public class GetSectorCragCommandHandler(ISectorRepository sectorRepository, IMapper mapper) : IRequestHandler<GetSectorCragCommand, CragDetailedDto>
{
    public async Task<CragDetailedDto> Handle(GetSectorCragCommand request, CancellationToken cancellationToken)
    {
        var crag = await sectorRepository.GetCragBySectorId(request.SectorId);

        if (crag == null)
        {
            throw new EntityNotFoundException("Sector not found");
        }

        return mapper.Map<CragDetailedDto>(crag);
    }
}
