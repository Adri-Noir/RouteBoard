using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Sectors.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Get;

public class GetSectorCommandHandler(IMapper mapper, ISectorRepository sectorRepository): IRequestHandler<GetSectorCommand, SectorDetailedDto>
{
    public async Task<SectorDetailedDto> Handle(GetSectorCommand request, CancellationToken cancellationToken)
    {
        var sector = await sectorRepository.GetSectorById(request.SectorId);
        
        if (sector == null)
        {
            throw new EntityNotFoundException("Sector not found.");
        }
        
        return mapper.Map<SectorDetailedDto>(sector);
    }
}