using System;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Users.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.GetAscents;

public class GetRouteAscentsCommandHandler(IRouteRepository routeRepository, IMapper mapper) : IRequestHandler<GetRouteAscentsCommand, ICollection<AscentDto>>
{
    public async Task<ICollection<AscentDto>> Handle(GetRouteAscentsCommand request, CancellationToken cancellationToken)
    {
        var route = await routeRepository.GetRouteById(request.Id, cancellationToken) ?? throw new EntityNotFoundException("Route not found");
        return mapper.Map<ICollection<AscentDto>>(route.Ascents);
    }
}
