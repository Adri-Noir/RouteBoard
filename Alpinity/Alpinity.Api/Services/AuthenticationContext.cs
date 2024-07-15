using System.Security.Claims;
using Alpinity.Application.Interfaces;

namespace Alpinity.Api.Services;

public class AuthenticationContext(IHttpContextAccessor httpContextAccessor) : IAuthenticationContext
{
    public Guid? GetUserId() =>
        httpContextAccessor.HttpContext?.User.Identity?.IsAuthenticated == true
            ? Guid.Parse(httpContextAccessor.HttpContext.User.FindFirstValue("uid")!)
            : null;
}
