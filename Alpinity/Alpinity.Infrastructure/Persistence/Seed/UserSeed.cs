using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
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
                Username = "seededUser",
                FirstName = "John",
                LastName = "Doe",
                Email = "john.doe@gmail.com",
                UserRole = UserRole.Admin,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("testpassword")
            };

            await context.Users.AddAsync(user);

            // Add a second user
            var secondUser = new User
            {
                Username = "seededUser2",
                FirstName = "Jane",
                LastName = "Smith",
                Email = "jane.smith@gmail.com",
                UserRole = UserRole.User,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("testpassword2")
            };

            await context.Users.AddAsync(secondUser);
            await context.SaveChangesAsync();
        }
    }
}