using MediatR;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using ApiExceptions.Exceptions;
using AutoMapper;

namespace Alpinity.Application.UseCases.Users.Commands.RecentlyAscendedRoutes;

public class RecentlyAscendedRoutesCommandHandler(IRouteRepository routeRepository, IUserRepository userRepository, IMapper mapper) : IRequestHandler<RecentlyAscendedRoutesCommand, ICollection<RecentlyAscendedRouteDto>>
{
    public async Task<ICollection<RecentlyAscendedRouteDto>> Handle(RecentlyAscendedRoutesCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetByIdAsync(request.UserId, cancellationToken);

        if (user == null)
        {
            throw new EntityNotFoundException("User not found");
        }

        var routes = await routeRepository.GetRecentlyAscendedRoutes(user.Id, cancellationToken);
        return mapper.Map<ICollection<RecentlyAscendedRouteDto>>(routes);
    }
}
