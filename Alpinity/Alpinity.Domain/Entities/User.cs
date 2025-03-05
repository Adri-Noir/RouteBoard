using System.ComponentModel.DataAnnotations;

namespace Alpinity.Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    [StringLength(50)]
    public required string Username { get; set; }
    [StringLength(100)]
    public required string Email { get; set; }
    [StringLength(100)]
    public required string PasswordHash { get; set; }

    [StringLength(50)]
    public string? FirstName { get; set; }
    [StringLength(50)]
    public string? LastName { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Photo>? TakenPhotos { get; set; }
    public Photo? ProfilePhoto { get; set; }
    public ICollection<Photo>? UserPhotoGallery { get; set; }
    public ICollection<Ascent>? Ascents { get; set; }
}