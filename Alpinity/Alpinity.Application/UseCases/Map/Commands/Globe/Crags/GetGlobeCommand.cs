using System.Text.Json.Serialization;
using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Map.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Map.Commands.Globe;

public class GetGlobeCommand : IRequest<ICollection<GlobeResponseDto>>
{
    public PointDto NorthEast { get; set; }
    public PointDto SouthWest { get; set; }
}
