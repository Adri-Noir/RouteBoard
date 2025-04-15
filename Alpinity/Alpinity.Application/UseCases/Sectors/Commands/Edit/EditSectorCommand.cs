using Alpinity.Application.UseCases.Sectors.Dtos;
using MediatR;
using Microsoft.AspNetCore.Http;
using System.Text.Json.Serialization;
using Alpinity.Application.Dtos;

namespace Alpinity.Application.UseCases.Sectors.Commands.Edit;

public class EditSectorCommand : IRequest<SectorDetailedDto>
{
    [JsonIgnore]
    public required Guid Id { get; set; }
    public string? Name { get; set; }
    public string? Description { get; set; }
    public PointDto? Location { get; set; }
    public ICollection<IFormFile>? Photos { get; set; }
    public ICollection<Guid>? PhotosToRemove { get; set; }
}