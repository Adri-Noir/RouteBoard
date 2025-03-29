using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Application.UseCases.Routes.Commands.AddPhoto;

public class AddRoutePhotoCommand : IRequest
{
    [FromForm]
    public Guid RouteId { get; set; }
    public IFormFile Photo { get; set; }
    public IFormFile LinePhoto { get; set; }
    public IFormFile CombinedPhoto { get; set; }
}