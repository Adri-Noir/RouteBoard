using System.Net.Mime;
using Alpinity.Application.UseCases.Routes.Commands.AddPhoto;
using Alpinity.Application.UseCases.Routes.Commands.Create;
using Alpinity.Application.UseCases.Routes.Commands.Get;
using Alpinity.Application.UseCases.Routes.Commands.GetAscents;
using Alpinity.Application.UseCases.Routes.Commands.GetPhotos;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Application.UseCases.Photos.Dtos;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;
using Alpinity.Api.ProblemDetails;
using Alpinity.Application.UseCases.Routes.Commands;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RouteController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(RouteDetailedDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<RouteDetailedDto>> GetRoute(Guid id, CancellationToken cancellationToken)
    {
        var command = new GetRouteCommand { Id = id };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(RouteDetailedDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [Consumes(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<RouteDetailedDto>> CreateRoute(CreateRouteCommand command,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }


    [HttpPost("/addPhoto")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [Consumes(MediaTypeNames.Multipart.FormData)]
    public async Task<ActionResult> AddPhoto(AddRoutePhotoCommand command,
        CancellationToken cancellationToken)
    {
        await mediator.Send(command, cancellationToken);
        return Ok();
    }

    [HttpGet("/routeAscents/{id:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(ICollection<AscentDto>), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<ICollection<AscentDto>>> GetRouteAscents(Guid id, CancellationToken cancellationToken)
    {
        var command = new GetRouteAscentsCommand { Id = id };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpGet("/routePhotos/{routeId:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(ICollection<ExtendedRoutePhotoDto>), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<ICollection<ExtendedRoutePhotoDto>>> GetRoutePhotos(Guid routeId, CancellationToken cancellationToken)
    {
        var command = new GetRoutePhotosCommand { RouteId = routeId };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK)]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<IActionResult> DeleteRoute(Guid id, CancellationToken cancellationToken)
    {
        await mediator.Send(new DeleteRouteCommand { RouteId = id }, cancellationToken);
        return Ok();
    }
}