using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

namespace Alpinity.Api.Extensions;

public static class AuthorizationExtensions
{
    public static IServiceCollection AddJwtAuthorization(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services
            .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.IncludeErrorDetails = true;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"])),
                    RequireSignedTokens = true,
                    RequireExpirationTime = true,
                    ValidateLifetime = true,
                    ValidateAudience = false,
                    ValidateIssuer = false
                };
                options.Events = new JwtBearerEvents
                {
                    OnTokenValidated = context =>
                    {
                        var claims = context.Principal.Claims;
                        var roleClaim = claims.FirstOrDefault(c => c.Type == "role");

                        if (roleClaim != null)
                        {
                            var claimsIdentity = context.Principal.Identity as ClaimsIdentity;
                            claimsIdentity?.AddClaim(new Claim(ClaimTypes.Role, roleClaim.Value));
                        }

                        return Task.CompletedTask;
                    }
                };
            });
        return services;
    }
}