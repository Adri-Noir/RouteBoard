using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Alpinity.Application.UseCases.Download.Commands.Crag.Get;
using Swashbuckle.AspNetCore.Annotations;
using Alpinity.Application.UseCases.Download.Dtos;
using Alpinity.Api.ProblemDetails;
using Alpinity.Application.UseCases.Download.Commands.Route.Get;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DownloadController(IMediator mediator) : ControllerBase
{
    [HttpGet("crag/{id:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(DownloadCragResponse), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult> DownloadCrag(Guid id, CancellationToken cancellationToken)
    {
        var command = new DownloadCragCommand { CragId = id };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpGet("route/{id:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(DownloadRouteResponse), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult> DownloadRoute(Guid id, CancellationToken cancellationToken)
    {
        var command = new DownloadRouteCommand { Id = id };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }
}