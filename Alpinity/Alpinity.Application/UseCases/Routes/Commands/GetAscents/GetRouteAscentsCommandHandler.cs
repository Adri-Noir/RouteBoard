using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Users.Dtos;
using AutoMapper;
using MediatR;
using ApiExceptions.Exceptions;

namespace Alpinity.Application.UseCases.Routes.Commands.GetAscents;

public class GetRouteAscentsCommandHandler(IRouteRepository routeRepository, IAscentRepository ascentRepository, IMapper mapper) : IRequestHandler<GetRouteAscentsCommand, ICollection<AscentDto>>
{
    public async Task<ICollection<AscentDto>> Handle(GetRouteAscentsCommand request, CancellationToken cancellationToken)
    {
        var routeExists = await routeRepository.RouteExists(request.Id, cancellationToken);
        if (!routeExists)
        {
            throw new EntityNotFoundException("Route not found");
        }

        var ascents = await ascentRepository.GetByRouteIdAsync(request.Id, cancellationToken);
        return mapper.Map<ICollection<AscentDto>>(ascents);
    }
}
