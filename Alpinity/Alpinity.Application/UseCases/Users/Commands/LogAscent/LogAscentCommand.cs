using System.Text.Json.Serialization;
using Alpinity.Domain.Enums;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.LogAscent;

public class LogAscentCommand : IRequest
{
    public required Guid RouteId { get; set; }
    public DateTime AscentDate { get; set; } = DateTime.UtcNow;
    public string? Notes { get; set; }
    public ICollection<ClimbType>? ClimbTypes { get; set; }
    public ICollection<RockType>? RockTypes { get; set; }
    public ICollection<HoldType>? HoldTypes { get; set; }
    public ClimbingGrade? ProposedGrade { get; set; }
    public int? Rating { get; set; }
    
    [JsonIgnore]
    public Guid UserId { get; set; }
} 