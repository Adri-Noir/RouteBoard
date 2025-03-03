using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Map.Dtos;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Map.Commands.Explore;

public class ExploreCommandHandler(ICragRepository cragRepository, IMapper mapper, IAscentRepository ascentRepository)
    : IRequestHandler<ExploreCommand, ICollection<ExploreDto>>
{
    public async Task<ICollection<ExploreDto>> Handle(ExploreCommand request, CancellationToken cancellationToken)
    {
        var userId = request.UserId;

        if (userId != null && (request.Latitude == null || request.Longitude == null))
        {
            var ascents = await ascentRepository.GetByUserIdAsync(userId.Value);

            if (ascents.Any())
            {
                var latestAscent = ascents.OrderByDescending(a => a.AscentDate).FirstOrDefault();
                if (latestAscent?.Route?.Sector?.Crag?.Location != null)
                {
                    var latestCrag = latestAscent.Route.Sector.Crag;
                    var latitude = latestCrag.Location.Y;
                    var longitude = latestCrag.Location.X;
                    var radius = request.Radius ?? 10000;

                    var crags = await cragRepository.GetCragsFromLocation(latitude, longitude, radius);
                    return mapper.Map<ICollection<ExploreDto>>(crags);
                }
            }
        }

        if (request.Latitude.HasValue && request.Longitude.HasValue)
        {
            var latitude = request.Latitude.Value;
            var longitude = request.Longitude.Value;
            var radius = request.Radius ?? 10000;

            var crags = await cragRepository.GetCragsFromLocation(latitude, longitude, radius);
            return mapper.Map<ICollection<ExploreDto>>(crags);
        }

        return [];
    }
}