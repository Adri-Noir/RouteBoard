using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class UserRepository(
    ApplicationDbContext dbContext) : IUserRepository
{
    public async Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await dbContext.Users
            .Include(u => u.ProfilePhoto)
            .FirstOrDefaultAsync(user => user.Id == id, cancellationToken);
    }

    public async Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await dbContext.Users
            .Include(u => u.ProfilePhoto)
            .FirstOrDefaultAsync(user => user.Email.ToLower() == email, cancellationToken);
    }

    public async Task<User?> GetByUsernameAsync(string username, CancellationToken cancellationToken = default)
    {
        return await dbContext.Users
            .Include(u => u.ProfilePhoto)
            .FirstOrDefaultAsync(user => user.Username.ToLower() == username, cancellationToken);
    }

    public async Task<ICollection<User>> GetUsersByUsernameAsync(string username, SearchOptionsDto searchOptions, CancellationToken cancellationToken = default)
    {
        return await dbContext.Users
            .Include(u => u.ProfilePhoto)
            .Include(u => u.Ascents!)
            .Where(user => EF.Functions.ILike(user.Username, $"%{username}%"))
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task<User> CreateAsync(User user, CancellationToken cancellationToken = default)
    {
        await dbContext.Users.AddAsync(user, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
        return user;
    }

    public async Task UpdateUser(User user, CancellationToken cancellationToken = default)
    {
        dbContext.Users.Update(user);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        throw new NotImplementedException();
    }

    public async Task ChangePhotoAsync(Guid userId, Photo photo, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users
            .Include(u => u.ProfilePhoto)
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

        user!.ProfilePhoto = photo;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<User?> GetUserProfileAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Users
            .Include(u => u.ProfilePhoto)
            .Include(u => u.Ascents!)
            .ThenInclude(a => a.Route!)
            .ThenInclude(r => r.Sector!)
            .ThenInclude(s => s.Crag!)
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
    }

    public async Task<ICollection<User>> GetAllUsersAsync(SearchOptionsDto searchOptions, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Users
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(searchOptions.Query))
        {
            query = query.Where(user => EF.Functions.ILike(user.Username, $"%{searchOptions.Query}%"));
        }

        return await query
            .OrderBy(u => u.Username)
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task<(ICollection<User> Users, int TotalCount)> GetAllUsersWithCountAsync(SearchOptionsDto searchOptions, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Users.AsQueryable();

        if (!string.IsNullOrWhiteSpace(searchOptions.Query))
        {
            query = query.Where(user => EF.Functions.ILike(user.Username, $"%{searchOptions.Query}%"));
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var users = await query
            .OrderBy(u => u.Username)
            .Skip(searchOptions.Page * searchOptions.PageSize)
            .Take(searchOptions.PageSize)
            .ToListAsync(cancellationToken);

        return (users, totalCount);
    }

    public async Task<bool> UserExistsAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Users.AnyAsync(u => u.Id == userId, cancellationToken);
    }
}