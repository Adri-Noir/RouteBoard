using Alpinity.Application.UseCases.Map.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Map.Commands.Globe.Sector;

public class GetGlobeSectorCommand : IRequest<ICollection<GlobeSectorResponseDto>>
{
    public Guid CragId { get; set; }
}
