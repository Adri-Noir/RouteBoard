using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.Edit;

public class EditRouteCommandHandler(IRouteRepository routeRepository, IMapper mapper, IAuthenticationContext authenticationContext, ICragRepository cragRepository) : IRequestHandler<EditRouteCommand, RouteDetailedDto>
{

    public async Task<RouteDetailedDto> Handle(EditRouteCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();

        var route = await routeRepository.GetRouteById(request.Id, cancellationToken) ?? throw new EntityNotFoundException("Route not found.");

        if (userRole != UserRole.Admin)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await routeRepository.IsUserCreatorOfRoute(request.Id, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to edit this route.");
            }
        }

        if (request.Name != null)
            route.Name = request.Name;
        if (request.Description != null)
            route.Description = request.Description;
        if (request.Grade != null)
            route.Grade = request.Grade;
        if (request.RouteType != null)
            route.RouteType = request.RouteType;
        if (request.Length != null)
            route.Length = request.Length;

        if (request.PhotosToRemove != null && request.PhotosToRemove.Any() && route.RoutePhotos != null)
        {
            route.RoutePhotos = route.RoutePhotos.Where(p => !request.PhotosToRemove.Contains(p.Id)).ToList();
        }

        await routeRepository.UpdateRoute(route, cancellationToken);

        return mapper.Map<RouteDetailedDto>(route);
    }
}