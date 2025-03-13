using Alpinity.Application.UseCases.Crags.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Commands.GetCrag;

public class GetSectorCragCommand : IRequest<CragDetailedDto>
{
    public Guid SectorId { get; set; }
}
