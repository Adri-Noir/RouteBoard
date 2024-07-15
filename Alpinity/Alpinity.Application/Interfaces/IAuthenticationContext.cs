namespace Alpinity.Application.Interfaces;

public interface IAuthenticationContext
{
    Guid? GetUserId();
}
