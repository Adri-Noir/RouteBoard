using Alpinity.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Persistence.Seed;

public class UserSeed
{
    public static async Task Seed(ApplicationDbContext context)
    {
        if (!await context.Users.AnyAsync())
        {
            var user = new User
            {
                Id = Guid.Empty,
                Username = "seededUser",
                FirstName = "John",
                LastName = "Doe",
                Email = "john.doe@gmail.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("testpassword")
            };

            await context.Users.AddAsync(user);
            await context.SaveChangesAsync();
        }
    }
}