using Alpinity.Application.UseCases.Crags.Dtos;
using MediatR;
using Microsoft.AspNetCore.Http;
using System.Text.Json.Serialization;
namespace Alpinity.Application.UseCases.Crags.Commands.Edit;

public class EditCragCommand : IRequest<CragDetailedDto>
{
    [JsonIgnore]
    public required Guid Id { get; set; }
    public string? Name { get; set; }
    public string? Description { get; set; }
    public ICollection<IFormFile>? Photos { get; set; }
    public string? LocationName { get; set; }
    public ICollection<Guid>? PhotosToRemove { get; set; }
}