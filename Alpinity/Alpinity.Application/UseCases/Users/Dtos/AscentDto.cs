using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Users.Dtos;

public class AscentDto
{
    public Guid Id { get; set; }
    public string AscentDate { get; set; }
    public string? Notes { get; set; }
    public ICollection<ClimbType>? ClimbTypes { get; set; }
    public ICollection<RockType>? RockTypes { get; set; }
    public ICollection<HoldType>? HoldTypes { get; set; }
    public ClimbingGrade? ProposedGrade { get; set; }
    public int? Rating { get; set; }


    public Guid UserId { get; set; }
    public string? Username { get; set; }
    public string? UserProfilePhotoUrl { get; set; }
}