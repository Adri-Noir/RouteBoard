using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Create;

public class CreateSectorCommandHandler(ISectorRepository repository, ICragRepository cragRepository, IMapper mapper) : IRequestHandler<CreateSectorCommand, SectorDetailedDto>
{
    public async Task<SectorDetailedDto> Handle(CreateSectorCommand request, CancellationToken cancellationToken)
    {
        var crag = await cragRepository.GetCragById(request.CragId);
        if (crag == null)
        {
            throw new EntityNotFoundException("Crag not found.");
        }
        
        var sector = new Sector
        {
            Name = request.Name,
            Description = request.Description,
            CragId = request.CragId
        };
        await repository.CreateSector(sector);
        
        return mapper.Map<SectorDetailedDto>(sector);
    }
}