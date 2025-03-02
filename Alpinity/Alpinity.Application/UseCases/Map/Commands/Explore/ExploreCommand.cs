using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.Crags.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Map.Commands.Explore;

public class ExploreCommand : IRequest<ICollection<CragDetailedDto>>
{
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public double? Radius { get; set; } = 10000;

    [JsonIgnore]
    public Guid? UserId { get; set; }
}
