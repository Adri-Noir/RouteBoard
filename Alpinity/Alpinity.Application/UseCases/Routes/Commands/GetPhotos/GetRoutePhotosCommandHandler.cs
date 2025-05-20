using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using MediatR;
using System.Collections.Generic;
using AutoMapper;
using ApiExceptions.Exceptions;

namespace Alpinity.Application.UseCases.Routes.Commands.GetPhotos;

public class GetRoutePhotosCommandHandler(
    IRouteRepository routeRepository,
    IMapper mapper) : IRequestHandler<GetRoutePhotosCommand, ICollection<DetectRoutePhotoDto>>
{
    public async Task<ICollection<DetectRoutePhotoDto>> Handle(GetRoutePhotosCommand request, CancellationToken cancellationToken)
    {
        // Check if route exists using the lightweight method
        var routeExists = await routeRepository.RouteExists(request.RouteId, cancellationToken);
        if (!routeExists)
        {
            throw new EntityNotFoundException("Route not found.");
        }

        var routePhotos = await routeRepository.GetRoutePhotos(request.RouteId, cancellationToken);

        if (routePhotos == null || !routePhotos.Any())
        {
            return new List<DetectRoutePhotoDto>();
        }

        return mapper.Map<ICollection<DetectRoutePhotoDto>>(routePhotos);
    }
}