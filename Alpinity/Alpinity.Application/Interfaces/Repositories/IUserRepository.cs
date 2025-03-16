using Alpinity.Application.Dtos;
using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> GetByUsernameAsync(string username, CancellationToken cancellationToken = default);
    Task<ICollection<User>> GetUsersByUsernameAsync(string username, SearchOptionsDto searchOptions, CancellationToken cancellationToken = default);
    Task<User> CreateAsync(User user, CancellationToken cancellationToken = default);
    Task<User> UpdateAsync(User user, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    Task ChangePhotoAsync(Guid userId, Photo photo, CancellationToken cancellationToken = default);
    Task<User?> GetUserProfileAsync(Guid userId, CancellationToken cancellationToken = default);
}