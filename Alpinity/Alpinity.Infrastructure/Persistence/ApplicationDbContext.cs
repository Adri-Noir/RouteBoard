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
    public DbSet<CragCreator> CragCreators { get; set; } = null!;
    public DbSet<Ascent> Ascents { get; set; } = null!;
    public DbSet<SearchHistory> SearchHistories { get; set; } = null!;
    public DbSet<CragWeather> CragWeathers { get; set; } = null!;

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

        modelBuilder.Entity<RoutePhoto>()
            .HasOne(rp => rp.CombinedPhoto)
            .WithOne(p => p.RouteCombinedPhoto)
            .HasForeignKey<RoutePhoto>(rp => rp.CombinedPhotoId)
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
            .HasMany(u => u.UserPhotoGallery)
            .WithOne(p => p.UserPhotoGallery)
            .HasForeignKey(p => p.UserPhotoGalleryId)
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

        modelBuilder.Entity<SearchHistory>()
            .HasOne(sh => sh.SearchingUser)
            .WithMany()
            .HasForeignKey(sh => sh.SearchingUserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<SearchHistory>()
            .HasOne(sh => sh.ProfileUser)
            .WithMany()
            .HasForeignKey(sh => sh.ProfileUserId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<SearchHistory>()
            .HasOne(sh => sh.Crag)
            .WithMany()
            .HasForeignKey(sh => sh.CragId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<SearchHistory>()
            .HasOne(sh => sh.Sector)
            .WithMany()
            .HasForeignKey(sh => sh.SectorId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<SearchHistory>()
            .HasOne(sh => sh.Route)
            .WithMany()
            .HasForeignKey(sh => sh.RouteId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<CragWeather>()
            .HasOne(cw => cw.Crag)
            .WithMany()
            .HasForeignKey(cw => cw.CragId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Crag>()
            .HasMany(c => c.Photos)
            .WithOne(p => p.Crag)
            .HasForeignKey(p => p.CragId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Sector>()
            .HasMany(s => s.Photos)
            .WithOne(p => p.Sector)
            .HasForeignKey(p => p.SectorId)
            .OnDelete(DeleteBehavior.Cascade);

        // Cascade delete sectors when deleting a crag
        modelBuilder.Entity<Crag>()
            .HasMany(c => c.Sectors)
            .WithOne(s => s.Crag)
            .HasForeignKey(s => s.CragId)
            .OnDelete(DeleteBehavior.Cascade);

        // Cascade delete routes when deleting a sector
        modelBuilder.Entity<Sector>()
            .HasMany(s => s.Routes)
            .WithOne(r => r.Sector)
            .HasForeignKey(r => r.SectorId)
            .OnDelete(DeleteBehavior.Cascade);

        // Cascade delete route photos when deleting a route
        modelBuilder.Entity<Route>()
            .HasMany(r => r.RoutePhotos)
            .WithOne(rp => rp.Route)
            .HasForeignKey(rp => rp.RouteId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<CragCreator>(entity =>
        {
            entity.HasKey(cc => new { cc.CragId, cc.UserId });
            entity.HasOne(cc => cc.Crag)
                .WithMany(c => c.CragCreators)
                .HasForeignKey(cc => cc.CragId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(cc => cc.User)
                .WithMany()
                .HasForeignKey(cc => cc.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}