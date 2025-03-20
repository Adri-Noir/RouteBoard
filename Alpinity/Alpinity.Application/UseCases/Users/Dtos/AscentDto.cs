using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Users.Dtos;

public class AscentDto : RouteCategoriesDto
{
    public Guid Id { get; set; }
    public string AscentDate { get; set; }
    public string? Notes { get; set; }

    public AscentType? AscentType { get; set; }
    public int? NumberOfAttempts { get; set; }
    public ClimbingGrade? ProposedGrade { get; set; }
    public int? Rating { get; set; }


    public Guid UserId { get; set; }
    public string? Username { get; set; }
    public string? UserProfilePhotoUrl { get; set; }
}