using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Alpinity.Infrastructure.Persistence.Seed;

public static class CragSectorRouteSeed
{
    public static async Task Seed(ApplicationDbContext context)
    {
        if (!await context.Crags.AnyAsync())
        {
            var crag = new Crag
            {
                Name = "Test Crag",
                Description = "This is a seeded crag.",
                Location = new Point(45.815399, 15.966568) { SRID = 4326 }
            };
            await context.Crags.AddAsync(crag);
            await context.SaveChangesAsync();
        }

        if (!await context.Sectors.AnyAsync())
        {
            var sector = new Sector
            {
                Name = "Test Sector",
                Description = "This is a seeded sector.",
                CragId = (await context.Crags.FirstAsync()).Id
            };
            await context.Sectors.AddAsync(sector);
            await context.SaveChangesAsync();
        }

        if (!await context.Routes.AnyAsync())
        {
            var route = new Route
            {
                Name = "Test Route",
                Description = "This is a seeded route.",
                Grade = ClimbingGrade.F_6a,
                RouteType = new List<RouteType> { RouteType.Sport, RouteType.Trad },
                SectorId = (await context.Sectors.FirstAsync()).Id
            };
            await context.Routes.AddAsync(route);
            await context.SaveChangesAsync();
        }

        if (!await context.Ascents.AnyAsync())
        {
            var user = await context.Users.FirstOrDefaultAsync();
            var route = await context.Routes.FirstOrDefaultAsync();

            if (user != null && route != null)
            {
                var ascent = new Ascent
                {
                    AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-5)),
                    Notes = "This is a seeded ascent. Great climbing day!",
                    ClimbTypes = [ClimbType.Technical, ClimbType.Powerful],
                    RockTypes = [RockType.Vertical, RockType.Arete],
                    HoldTypes = [HoldType.Crimps, HoldType.Jugs],
                    ProposedGrade = ClimbingGrade.F_6a,
                    Rating = 4,
                    UserId = user.Id,
                    RouteId = route.Id
                };

                await context.Ascents.AddAsync(ascent);
                await context.SaveChangesAsync();
            }
        }
    }
}