using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Application.UseCases.Crags.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Commands.GetCrag;

public class GetSectorCragCommandHandler(
    ISectorRepository sectorRepository,
    IMapper mapper,
    IEntityPermissionService permissionService) : IRequestHandler<GetSectorCragCommand, CragDetailedDto>
{
    public async Task<CragDetailedDto> Handle(GetSectorCragCommand request, CancellationToken cancellationToken)
    {
        var crag = await sectorRepository.GetCragBySectorId(request.SectorId, cancellationToken);

        if (crag == null)
        {
            throw new EntityNotFoundException("Sector not found");
        }

        var dto = mapper.Map<CragDetailedDto>(crag);
        dto.CanModify = await permissionService.CanModifyCrag(crag.Id, cancellationToken);

        return dto;
    }
}
