using Alpinity.Domain.Enums;

namespace Alpinity.Domain.Entities;

public class SearchHistory
{
    public Guid Id { get; set; }
    public SearchResultItemType EntityType { get; set; }

    // Entity references - only one of these will be set based on what was viewed
    public Guid? CragId { get; set; }
    public Crag? Crag { get; set; }

    public Guid? SectorId { get; set; }
    public Sector? Sector { get; set; }

    public Guid? RouteId { get; set; }
    public Route? Route { get; set; }

    // User profile that was accessed (optional)
    public Guid? ProfileUserId { get; set; }
    public User? ProfileUser { get; set; }

    // Required user reference - the user who performed the search
    public Guid SearchingUserId { get; set; }
    public User SearchingUser { get; set; } = null!;

    public DateTime SearchedAt { get; set; }
}