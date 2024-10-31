using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.Sectors.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Get;

public class GetSectorCommand: IRequest<SectorDetailedDto>
{
    [JsonIgnore] public Guid SectorId { get; set; }
}