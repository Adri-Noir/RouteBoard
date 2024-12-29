using MediatR;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.UseCases.Routes.Commands.AddPhoto;

public class AddRoutePhotoCommand : IRequest
{
    public required Guid RouteId { get; set; }
    public IFormFile Photo { get; set; }
    public IFormFile LinePhoto { get; set; }
}