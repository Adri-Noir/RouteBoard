using System.Net.Mime;
using Alpinity.Application.UseCases.Routes.Commands.AddPhoto;
using Alpinity.Application.UseCases.Routes.Commands.Get;
using Alpinity.Application.UseCases.Routes.Dtos;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RouteController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<RouteDetailedDto>> GetRoute(Guid routeId, CancellationToken cancellationToken)
    {
        var command = new GetRouteCommand { Id = routeId };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpPost("/addPhoto")]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult> AddPhoto(AddRoutePhotoCommand command,
        CancellationToken cancellationToken)
    {
        await mediator.Send(command, cancellationToken);
        return Ok();
    }
}