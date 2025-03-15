using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Map.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Map.Commands.Globe.Sector;

public class GetGlobeSectorCommandHandler(ISectorRepository sectorRepository, ICragRepository cragRepository, IMapper mapper) : IRequestHandler<GetGlobeSectorCommand, ICollection<GlobeSectorResponseDto>>
{
    public async Task<ICollection<GlobeSectorResponseDto>> Handle(GetGlobeSectorCommand request, CancellationToken cancellationToken)
    {
        var cragExists = await cragRepository.CragExists(request.CragId, cancellationToken);
        if (!cragExists)
        {
            throw new EntityNotFoundException($"Crag with id {request.CragId} not found");
        }

        var sectors = await sectorRepository.GetSectorsOnlyByCragId(request.CragId, cancellationToken);
        return mapper.Map<ICollection<GlobeSectorResponseDto>>(sectors);
    }
}
