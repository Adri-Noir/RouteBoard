using MediatR;
using System.Collections.Generic;
using Alpinity.Application.UseCases.Photos.Dtos;

namespace Alpinity.Application.UseCases.Routes.Commands.GetPhotos;

public class GetRoutePhotosCommand : IRequest<ICollection<DetectRoutePhotoDto>>
{
    public Guid RouteId { get; set; }
}