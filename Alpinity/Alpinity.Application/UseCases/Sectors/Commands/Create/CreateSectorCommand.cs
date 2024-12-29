using Alpinity.Application.UseCases.Sectors.Dtos;
using MediatR;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.UseCases.Sectors.Commands.Create;

public class CreateSectorCommand: IRequest<SectorDetailedDto>
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public List<IFormFile> Photos { get; set; }
    public Guid CragId { get; set; }
}