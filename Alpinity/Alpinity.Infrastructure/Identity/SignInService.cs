using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Alpinity.Application.Configuration;
using Alpinity.Application.Services;
using Alpinity.Domain.Entities;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Alpinity.Infrastructure.Identity;

public class SignInService : ISignInService
{
    private readonly JwtConfiguration _jwtConfiguration;

    public SignInService(IOptions<JwtConfiguration> jwtConfiguration)
    {
        _jwtConfiguration = jwtConfiguration.Value;
    }

    public string GenerateJwToken(User user)
    {
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, user.Username),
            new Claim("uid", user.Id.ToString()),
            new Claim("role", user.UserRole.ToString())
        };

        var symmetricSecurityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtConfiguration.Key));
        var signingCredentials = new SigningCredentials(symmetricSecurityKey, SecurityAlgorithms.HmacSha256);

        return new JwtSecurityTokenHandler().WriteToken(
            new JwtSecurityToken(
                _jwtConfiguration.Issuer,
                _jwtConfiguration.Audience,
                claims,
                expires: DateTime.UtcNow.AddMinutes(_jwtConfiguration.DurationInMinutes),
                signingCredentials: signingCredentials));
    }

    public string HashPassword(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public bool CheckPasswordHash(string passwordHash, string password)
    {
        return BCrypt.Net.BCrypt.Verify(password, passwordHash);
    }

    public bool PasswordIsStrong(string password)
    {
        return password.Length >= 8
               && password.Any(char.IsUpper)
               && password.Any(char.IsDigit)
               && password.Any(c => !char.IsLetterOrDigit(c));
    }
}