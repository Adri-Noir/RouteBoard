using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Sectors.Dtos;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
namespace Alpinity.Application.UseCases.Sectors.Commands.Create;

public class CreateSectorCommand : IRequest<SectorDetailedDto>
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public PointDto? Location { get; set; }
    public required Guid CragId { get; set; }
    public ICollection<IFormFile>? Photos { get; set; }
}