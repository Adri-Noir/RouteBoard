using MediatR;
using Alpinity.Application.UseCases.Routes.Dtos;

namespace Alpinity.Application.UseCases.Users.Commands.RecentlyAscendedRoutes;

public class RecentlyAscendedRoutesCommand : IRequest<ICollection<RecentlyAscendedRouteDto>>
{
    public Guid UserId { get; set; }
}
