using System.Reflection;
using Alpinity.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Persistence;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<Crag> Crags { get; set; } = null!;
    public DbSet<Sector> Sectors { get; set; } = null!;
    public DbSet<Route> Routes { get; set; } = null!;
    public DbSet<RoutePhoto> RoutePhotos { get; set; } = null!;
    public DbSet<Photo> Photos { get; set; } = null!;
    public DbSet<Ascent> Ascents { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

        modelBuilder.Entity<RoutePhoto>()
            .HasOne(rp => rp.Image)
            .WithOne(p => p.RouteImage)
            .HasForeignKey<RoutePhoto>(rp => rp.ImageId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<RoutePhoto>()
            .HasOne(rp => rp.PathLine)
            .WithOne(p => p.RoutePathLine)
            .HasForeignKey<RoutePhoto>(rp => rp.PathLineId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<User>()
            .HasMany(u => u.TakenPhotos)
            .WithOne(p => p.TakenByUser)
            .HasForeignKey(p => p.TakenByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<User>()
            .HasOne(u => u.ProfilePhoto)
            .WithOne(p => p.UserPhoto)
            .HasForeignKey<Photo>(u => u.UserPhotoId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<User>()
            .HasIndex(u => u.Username)
            .IsUnique();

        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();
            
        modelBuilder.Entity<Ascent>()
            .HasOne(a => a.User)
            .WithMany(u => u.Ascents)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);
            
        modelBuilder.Entity<Ascent>()
            .HasOne(a => a.Route)
            .WithMany(r => r.Ascents)
            .HasForeignKey(a => a.RouteId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}