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
            var crags = new List<Crag>
            {
                new Crag
                {
                    Name = "Test Crag 1",
                    Description = "This is a seeded crag.",
                    Location = new Point(15.966568, 45.815399) { SRID = 4326 },
                    LocationName = "Test Crag 1"
                },
                new Crag
                {
                    Name = "Test Crag 2",
                    Description = "This is a second seeded crag.",
                    Location = new Point(16.373244, 46.554725) { SRID = 4326 },
                    LocationName = "Test Crag 2"
                },
                new Crag
                {
                    Name = "Paklenica",
                    Description = "Famous Croatian climbing area with limestone walls.",
                    Location = new Point(15.487778, 44.293889) { SRID = 4326 },
                    LocationName = "Zadar, Croatia"
                },
                new Crag
                {
                    Name = "Fontainebleau",
                    Description = "World-renowned bouldering area in France.",
                    Location = new Point(2.699444, 48.404722) { SRID = 4326 },
                    LocationName = "Fontainebleau, France"
                },
                new Crag
                {
                    Name = "El Capitan",
                    Description = "Iconic big wall climbing in Yosemite National Park.",
                    Location = new Point(-119.637778, 37.733333) { SRID = 4326 },
                    LocationName = "Yosemite National Park, USA"
                },
                new Crag
                {
                    Name = "Kalymnos",
                    Description = "Greek island known for its sport climbing on limestone.",
                    Location = new Point(26.983333, 36.966667) { SRID = 4326 },
                    LocationName = "Kalymnos, Greece"
                },
                new Crag
                {
                    Name = "Ceüse",
                    Description = "Premier limestone cliff in France with challenging routes.",
                    Location = new Point(5.936576, 44.518188) { SRID = 4326 },
                    LocationName = "Vaucluse, France"
                }
            };

            await context.Crags.AddRangeAsync(crags);
            await context.SaveChangesAsync();
        }

        if (!await context.Sectors.AnyAsync())
        {
            var crags = await context.Crags.ToListAsync();
            var sectors = new List<Sector>();

            // For Test Crag 1
            sectors.Add(new Sector
            {
                Name = "Test Sector",
                Description = "This is a seeded sector.",
                CragId = crags[0].Id,
                Location = new Point(15.966768, 45.815599) { SRID = 4326 }
            });

            sectors.Add(new Sector
            {
                Name = "Test Sector 2",
                Description = "This is a second seeded sector.",
                CragId = crags[0].Id,
                Location = new Point(15.967368, 45.816199) { SRID = 4326 }
            });

            // For Paklenica
            sectors.Add(new Sector
            {
                Name = "Anića Kuk",
                Description = "The main wall of Paklenica with many classic routes.",
                CragId = crags.First(c => c.Name == "Paklenica").Id,
                Location = new Point(15.488778, 44.294889) { SRID = 4326 }
            });

            sectors.Add(new Sector
            {
                Name = "Klanci",
                Description = "Area with shorter routes, good for beginners.",
                CragId = crags.First(c => c.Name == "Paklenica").Id,
                Location = new Point(15.486778, 44.292889) { SRID = 4326 }
            });

            // For Fontainebleau
            sectors.Add(new Sector
            {
                Name = "Bas Cuvier",
                Description = "Popular area with a wide range of boulder problems.",
                CragId = crags.First(c => c.Name == "Fontainebleau").Id,
                Location = new Point(2.698444, 48.403722) { SRID = 4326 }
            });

            sectors.Add(new Sector
            {
                Name = "Franchard Isatis",
                Description = "Famous for its technical slabs and crimpy problems.",
                CragId = crags.First(c => c.Name == "Fontainebleau").Id,
                Location = new Point(2.700444, 48.405722) { SRID = 4326 }
            });

            // For El Capitan
            sectors.Add(new Sector
            {
                Name = "The Nose",
                Description = "The most famous big wall route in the world.",
                CragId = crags.First(c => c.Name == "El Capitan").Id,
                Location = new Point(-119.636778, 37.732333) { SRID = 4326 }
            });

            sectors.Add(new Sector
            {
                Name = "Freerider",
                Description = "Famous free climbing route on El Capitan.",
                CragId = crags.First(c => c.Name == "El Capitan").Id,
                Location = new Point(-119.638778, 37.734333) { SRID = 4326 }
            });

            // For Kalymnos
            sectors.Add(new Sector
            {
                Name = "Grande Grotta",
                Description = "Spectacular cave with 3D climbing on tufas.",
                CragId = crags.First(c => c.Name == "Kalymnos").Id,
                Location = new Point(26.984333, 36.967667) { SRID = 4326 }
            });

            sectors.Add(new Sector
            {
                Name = "Odyssey",
                Description = "Beautiful sector with technical routes on good rock.",
                CragId = crags.First(c => c.Name == "Kalymnos").Id,
                Location = new Point(26.982333, 36.965667) { SRID = 4326 }
            });

            // For Ceüse
            sectors.Add(new Sector
            {
                Name = "Biographie Sector",
                Description = "Home to the famous Biographie/Realization route.",
                CragId = crags.First(c => c.Name == "Ceüse").Id,
                Location = new Point(5.937576, 44.519188) { SRID = 4326 }
            });

            sectors.Add(new Sector
            {
                Name = "Berlin",
                Description = "Sector with many challenging routes.",
                CragId = crags.First(c => c.Name == "Ceüse").Id,
                Location = new Point(5.935576, 44.517188) { SRID = 4326 }
            });

            await context.Sectors.AddRangeAsync(sectors);
            await context.SaveChangesAsync();
        }

        if (!await context.Routes.AnyAsync())
        {
            var sectors = await context.Sectors.ToListAsync();
            var routes = new List<Route>
            {
                // Original test route
                new Route
                {
                    Name = "Test Route",
                    Description = "This is a seeded route.",
                    Grade = ClimbingGrade.F_6a,
                    RouteType = new List<RouteType> { RouteType.Sport, RouteType.Trad },
                    SectorId = sectors.First(s => s.Name == "Test Sector").Id,
                    Length = 10
                },
                
                // Additional routes for Test Sector
                new Route
                {
                    Name = "Crimpy Face",
                    Description = "Technical face climbing with small crimps.",
                    Grade = ClimbingGrade.F_6b,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Test Sector").Id,
                    Length = 10
                },
                
                // Routes for Test Sector 2
                new Route
                {
                    Name = "Overhang Challenge",
                    Description = "Powerful climbing on steep terrain.",
                    Grade = ClimbingGrade.F_7a,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Test Sector 2").Id,
                    Length = 10
                },
                
                // Routes for Anića Kuk
                new Route
                {
                    Name = "Mosoraški",
                    Description = "Classic multi-pitch route on Anića Kuk.",
                    Grade = ClimbingGrade.F_6a_plus,
                    RouteType = new List<RouteType> { RouteType.Sport, RouteType.MultiPitch },
                    SectorId = sectors.First(s => s.Name == "Anića Kuk").Id,
                    Length = 60
                },

                new Route
                {
                    Name = "Funkcija",
                    Description = "Hard and technical route with small holds.",
                    Grade = ClimbingGrade.F_7c,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Anića Kuk").Id,
                    Length = 20
                },
                
                // Routes for Klanci
                new Route
                {
                    Name = "Beginner's Delight",
                    Description = "Perfect route for beginners with good holds.",
                    Grade = ClimbingGrade.F_5a,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Klanci").Id,
                    Length = 17
                },
                
                // Routes for Bas Cuvier
                new Route
                {
                    Name = "Duroxmanie",
                    Description = "Classic boulder problem.",
                    Grade = ClimbingGrade.F_6c,
                    RouteType = new List<RouteType> { RouteType.Boulder },
                    SectorId = sectors.First(s => s.Name == "Bas Cuvier").Id,
                    Length = 4
                },
                
                // Routes for Franchard Isatis
                new Route
                {
                    Name = "La Marie Rose",
                    Description = "Famous boulder problem, a must-do.",
                    Grade = ClimbingGrade.F_6a,
                    RouteType = new List<RouteType> { RouteType.Boulder },
                    SectorId = sectors.First(s => s.Name == "Franchard Isatis").Id,
                    Length = 5
                },
                
                // Routes for The Nose
                new Route
                {
                    Name = "The Nose",
                    Description = "The most famous big wall route in the world.",
                    Grade = ClimbingGrade.F_8a,
                    RouteType = new List<RouteType> { RouteType.BigWall, RouteType.Trad, RouteType.Aid },
                    SectorId = sectors.First(s => s.Name == "The Nose").Id,
                    Length = 900
                },
                
                // Routes for Freerider
                new Route
                {
                    Name = "Freerider",
                    Description = "Famous free climbing route on El Capitan.",
                    Grade = ClimbingGrade.F_7c_plus,
                    RouteType = new List<RouteType> { RouteType.BigWall, RouteType.Trad },
                    SectorId = sectors.First(s => s.Name == "Freerider").Id,
                    Length = 1000
                },
                
                // Routes for Grande Grotta
                new Route
                {
                    Name = "Aegialis",
                    Description = "Classic route through the cave with 3D climbing.",
                    Grade = ClimbingGrade.F_7a,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Grande Grotta").Id,
                    Length = 25
                },

                new Route
                {
                    Name = "DNA",
                    Description = "Spectacular route with tufa climbing.",
                    Grade = ClimbingGrade.F_7b_plus,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Grande Grotta").Id,
                    Length = 30
                },
                
                // Routes for Odyssey
                new Route
                {
                    Name = "Priapos",
                    Description = "Technical face climbing on good rock.",
                    Grade = ClimbingGrade.F_6c_plus,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Odyssey").Id,
                    Length = 22
                },
                
                // Routes for Biographie Sector
                new Route
                {
                    Name = "Biographie",
                    Description = "One of the most famous sport routes in the world.",
                    Grade = ClimbingGrade.F_9a_plus,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Biographie Sector").Id,
                    Length = 35
                },
                
                // Routes for Berlin
                new Route
                {
                    Name = "Berlin",
                    Description = "Hard and technical route on small holds.",
                    Grade = ClimbingGrade.F_8b,
                    RouteType = new List<RouteType> { RouteType.Sport },
                    SectorId = sectors.First(s => s.Name == "Berlin").Id,
                    Length = 28
                }
            };

            await context.Routes.AddRangeAsync(routes);
            await context.SaveChangesAsync();
        }

        if (!await context.Ascents.AnyAsync())
        {
            var user = await context.Users.FirstOrDefaultAsync(u => u.Username == "seededUser");
            var secondUser = await context.Users.FirstOrDefaultAsync(u => u.Username == "seededUser2");
            var routes = await context.Routes.ToListAsync();

            if (user != null && secondUser != null && routes.Any())
            {
                var ascents = new List<Ascent>
                {
                    // Original ascent for John Doe
                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-5)),
                        Notes = "This is a seeded ascent. Great climbing day!",
                        ClimbTypes = [ClimbType.Technical, ClimbType.Powerful],
                        RockTypes = [RockType.Vertical, RockType.Arete],
                        HoldTypes = [HoldType.Crimps, HoldType.Jugs],
                        ProposedGrade = ClimbingGrade.F_6a,
                        Rating = 4,
                        AscentType = AscentType.Flash,
                        UserId = user.Id,
                        RouteId = routes.First(r => r.Name == "Test Route").Id
                    },

                    // Additional ascents for John Doe
                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-10)),
                        Notes = "Struggled with the crux move but finally sent it!",
                        ClimbTypes = [ClimbType.Powerful],
                        RockTypes = [RockType.Overhang],
                        HoldTypes = [HoldType.Crimps, HoldType.Pinches],
                        ProposedGrade = ClimbingGrade.F_7a,
                        Rating = 5,
                        AscentType = AscentType.Redpoint,
                        UserId = user.Id,
                        RouteId = routes.First(r => r.Name == "Overhang Challenge").Id
                    },

                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-15)),
                        Notes = "Beautiful line with technical moves. Loved it!",
                        ClimbTypes = [ClimbType.Technical],
                        RockTypes = [RockType.Vertical],
                        HoldTypes = [HoldType.Crimps],
                        ProposedGrade = ClimbingGrade.F_6b,
                        Rating = 4,
                        AscentType = AscentType.Onsight,
                        UserId = user.Id,
                        RouteId = routes.First(r => r.Name == "Crimpy Face").Id
                    },

                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-30)),
                        Notes = "Classic multi-pitch route. Amazing views from the top!",
                        ClimbTypes = [ClimbType.Endurance, ClimbType.Technical],
                        RockTypes = [RockType.Vertical, RockType.Slab],
                        HoldTypes = [HoldType.Jugs, HoldType.Crimps],
                        ProposedGrade = ClimbingGrade.F_6a_plus,
                        Rating = 5,
                        AscentType = AscentType.Redpoint,
                        UserId = user.Id,
                        RouteId = routes.First(r => r.Name == "Mosoraški").Id
                    },

                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-45)),
                        Notes = "Perfect boulder problem for beginners. Fun moves!",
                        ClimbTypes = [ClimbType.Technical],
                        RockTypes = [RockType.Slab],
                        HoldTypes = [HoldType.Jugs],
                        ProposedGrade = ClimbingGrade.F_6a,
                        Rating = 3,
                        AscentType = AscentType.Flash,
                        UserId = user.Id,
                        RouteId = routes.First(r => r.Name == "La Marie Rose").Id
                    },

                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-60)),
                        Notes = "Amazing tufa climbing in a spectacular setting!",
                        ClimbTypes = [ClimbType.Powerful, ClimbType.Endurance],
                        RockTypes = [RockType.Overhang, RockType.Roof],
                        HoldTypes = [HoldType.Jugs, HoldType.Pinches],
                        ProposedGrade = ClimbingGrade.F_7a,
                        Rating = 5,
                        AscentType = AscentType.Redpoint,
                        UserId = user.Id,
                        RouteId = routes.First(r => r.Name == "Aegialis").Id
                    },

                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-75)),
                        Notes = "Technical face climbing on perfect limestone.",
                        ClimbTypes = [ClimbType.Technical],
                        RockTypes = [RockType.Vertical],
                        HoldTypes = [HoldType.Crimps, HoldType.Pockets],
                        ProposedGrade = ClimbingGrade.F_6c_plus,
                        Rating = 4,
                        AscentType = AscentType.Flash,
                        UserId = user.Id,
                        RouteId = routes.First(r => r.Name == "Priapos").Id
                    },
                    
                    // Ascents for Jane Smith
                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-7)),
                        Notes = "First ascent! Felt great on this route.",
                        ClimbTypes = [ClimbType.Technical],
                        RockTypes = [RockType.Vertical],
                        HoldTypes = [HoldType.Crimps, HoldType.Jugs],
                        ProposedGrade = ClimbingGrade.F_6a,
                        Rating = 4,
                        AscentType = AscentType.Onsight,
                        UserId = secondUser.Id,
                        RouteId = routes.First(r => r.Name == "Test Route").Id
                    },
                    new Ascent
                    {
                        AscentDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-12)),
                        Notes = "Challenging overhang, but managed to send it!",
                        ClimbTypes = [ClimbType.Powerful],
                        RockTypes = [RockType.Overhang],
                        HoldTypes = [HoldType.Pinches, HoldType.Slopers],
                        ProposedGrade = ClimbingGrade.F_6b,
                        Rating = 5,
                        AscentType = AscentType.Redpoint,
                        UserId = secondUser.Id,
                        RouteId = routes.First(r => r.Name == "Crimpy Face").Id
                    }
                };

                await context.Ascents.AddRangeAsync(ascents);
                await context.SaveChangesAsync();
            }
        }
    }
}