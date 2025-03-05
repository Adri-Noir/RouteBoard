using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id);
    Task<User?> GetByEmailAsync(string email);
    Task<User?> GetByUsernameAsync(string username);
    Task<User> CreateAsync(User user);
    Task<User> UpdateAsync(User user);
    Task DeleteAsync(Guid id);
    Task ChangePhotoAsync(Guid userId, Photo photo);
    Task<User?> GetUserProfileAsync(Guid userId);
}