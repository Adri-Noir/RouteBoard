using Alpinity.Domain.Entities;

namespace Alpinity.Application.Services;

public interface ISignInService
{
    public string GenerateJwToken(User user);
    public string HashPassword(string password);
    public bool CheckPasswordHash(string passwordHash, string password);
    public bool PasswordIsStrong(string password);
}