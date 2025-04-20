using Alpinity.Application.UseCases.Routes.Dtos;
using MediatR;
using Microsoft.AspNetCore.Http;
using System.Text.Json.Serialization;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Routes.Commands.Edit;

public class EditRouteCommand : IRequest<RouteDetailedDto>
{
    [JsonIgnore]
    public Guid Id { get; set; }
    public string? Name { get; set; }
    public string? Description { get; set; }
    public ClimbingGrade? Grade { get; set; }
    public ICollection<RouteType>? RouteType { get; set; }
    public int? Length { get; set; }
    public ICollection<Guid>? PhotosToRemove { get; set; }
}