using Alpinity.Domain.Enums;
using System.ComponentModel.DataAnnotations;

namespace Alpinity.Domain.Entities;

public class Ascent
{
    public Guid Id { get; set; }
    public DateOnly AscentDate { get; set; } = DateOnly.FromDateTime(DateTime.UtcNow);
    [StringLength(2000)]
    public string? Notes { get; set; }
    public ICollection<ClimbType>? ClimbTypes { get; set; }
    public ICollection<RockType>? RockTypes { get; set; }
    public ICollection<HoldType>? HoldTypes { get; set; }
    public ClimbingGrade? ProposedGrade { get; set; }
    public int? Rating { get; set; }
    
    public Guid UserId { get; set; }
    public User? User { get; set; }
    
    public Guid RouteId { get; set; }
    public Route? Route { get; set; }
} 