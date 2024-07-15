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
    }
}