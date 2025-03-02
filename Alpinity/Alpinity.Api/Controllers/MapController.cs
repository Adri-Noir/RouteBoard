using System.Net.Mime;
using Alpinity.Application.Interfaces;
using Alpinity.Application.UseCases.Map.Commands.Explore;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MapController(IMediator mediator, IAuthenticationContext authenticationContext) : ControllerBase
{
    [HttpGet("explore")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<IActionResult> Explore(double? latitude, double? longitude, double? radius, CancellationToken cancellationToken)
    {
        var command = new ExploreCommand
        {
            Latitude = latitude,
            Longitude = longitude,
            Radius = radius,
            UserId = (Guid)authenticationContext.GetUserId()!
        };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }
}
