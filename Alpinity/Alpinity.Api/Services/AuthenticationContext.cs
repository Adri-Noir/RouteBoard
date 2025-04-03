using System.Security.Claims;
using Alpinity.Application.Interfaces;
using Alpinity.Domain.Enums;

namespace Alpinity.Api.Services;

public class AuthenticationContext(IHttpContextAccessor httpContextAccessor) : IAuthenticationContext
{
    public Guid? GetUserId()
    {
        return httpContextAccessor.HttpContext?.User.Identity?.IsAuthenticated == true
            ? Guid.Parse(httpContextAccessor.HttpContext.User.FindFirstValue("uid")!)
            : null;
    }

    public UserRole GetUserRole()
    {
        if (httpContextAccessor.HttpContext?.User.Identity?.IsAuthenticated != true)
            return UserRole.User;

        var roleClaim = httpContextAccessor.HttpContext.User.Claims
            .FirstOrDefault(c => c.Type == ClaimTypes.Role || c.Type == "role");

        if (roleClaim != null && Enum.TryParse(roleClaim.Value, out UserRole role))
            return role;

        return UserRole.User;
    }

    public string? GetJwtToken()
    {
        var authorizationHeader = httpContextAccessor.HttpContext?.Request.Headers.Authorization.FirstOrDefault();

        if (!string.IsNullOrEmpty(authorizationHeader) &&
            authorizationHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            return authorizationHeader.Substring("Bearer ".Length).Trim();

        return null;
    }
}