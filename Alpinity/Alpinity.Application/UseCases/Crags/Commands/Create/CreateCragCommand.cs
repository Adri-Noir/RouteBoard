using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Crags.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommand : IRequest<CragDetailedDto>
{
    public required string Name { get; set; }
    public string? Description { get; set; }
}