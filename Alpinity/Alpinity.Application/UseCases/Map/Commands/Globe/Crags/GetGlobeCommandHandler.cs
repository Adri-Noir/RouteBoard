
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Map.Dtos;
using AutoMapper;
using MediatR;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.UseCases.Map.Commands.Globe;

public class GetGlobeCommandHandler(ICragRepository cragRepository, IMapper mapper) : IRequestHandler<GetGlobeCommand, ICollection<GlobeResponseDto>>
{
    public async Task<ICollection<GlobeResponseDto>> Handle(GetGlobeCommand request, CancellationToken cancellationToken)
    {
        var northEast = mapper.Map<Point>(request.NorthEast);
        var southWest = mapper.Map<Point>(request.SouthWest);
        var crags = await cragRepository.GetCragsByBoundingBox(northEast, southWest, cancellationToken);
        return mapper.Map<ICollection<GlobeResponseDto>>(crags);
    }
}
