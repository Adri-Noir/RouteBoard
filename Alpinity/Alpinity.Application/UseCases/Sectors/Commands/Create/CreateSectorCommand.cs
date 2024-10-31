using Alpinity.Application.UseCases.Sectors.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Create;

public class CreateSectorCommand: IRequest<SectorDetailedDto>
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public Guid CragId { get; set; }
}