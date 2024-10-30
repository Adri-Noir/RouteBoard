using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.Crags.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.Get;

public record GetCragCommand: IRequest<CragDetailedDto>
{
    [JsonIgnore] public Guid CragId { get; set; }
}