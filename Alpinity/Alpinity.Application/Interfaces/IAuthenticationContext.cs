using Alpinity.Domain.Enums;

namespace Alpinity.Application.Interfaces;

public interface IAuthenticationContext
{
    Guid? GetUserId();
    UserRole GetUserRole();
    string? GetJwtToken();
}