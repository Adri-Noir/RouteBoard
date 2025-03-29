using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using MediatR;
using System.Collections.Generic;
using AutoMapper;
using ApiExceptions.Exceptions;

namespace Alpinity.Application.UseCases.Routes.Commands.GetPhotos;

public class GetRoutePhotosCommandHandler(
    IRouteRepository routeRepository,
    IMapper mapper) : IRequestHandler<GetRoutePhotosCommand, ICollection<ExtendedRoutePhotoDto>>
{
    public async Task<ICollection<ExtendedRoutePhotoDto>> Handle(GetRoutePhotosCommand request, CancellationToken cancellationToken)
    {
        // Check if route exists using the lightweight method
        var routeExists = await routeRepository.RouteExists(request.RouteId, cancellationToken);
        if (!routeExists)
        {
            throw new EntityNotFoundException("Route not found.");
        }

        // Get route photos directly from repository
        var routePhotos = await routeRepository.GetRoutePhotos(request.RouteId, cancellationToken);

        if (routePhotos == null || !routePhotos.Any())
        {
            return new List<ExtendedRoutePhotoDto>();
        }

        // Use mapper to map the routePhotos collection to ExtendedRoutePhotoDto
        return mapper.Map<ICollection<ExtendedRoutePhotoDto>>(routePhotos);
    }
}