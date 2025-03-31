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
        return httpContextAccessor.HttpContext?.User.Identity?.IsAuthenticated == true
            && Enum.TryParse(httpContextAccessor.HttpContext.User.FindFirstValue("role"), out UserRole role)
                ? role
                : UserRole.User;
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