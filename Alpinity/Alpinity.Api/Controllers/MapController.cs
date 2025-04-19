using System.Net.Mime;
using Alpinity.Api.ProblemDetails;
using Alpinity.Application.Interfaces;
using Alpinity.Application.UseCases.Map.Commands.Explore;
using Alpinity.Application.UseCases.Map.Commands.Globe.Crags;
using Alpinity.Application.UseCases.Map.Commands.Globe.Sector;
using Alpinity.Application.UseCases.Map.Commands.Weather;
using Alpinity.Application.UseCases.Map.Dtos;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MapController(IMediator mediator, IAuthenticationContext authenticationContext) : ControllerBase
{
    [HttpGet("explore")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(ICollection<ExploreDto>), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<ICollection<ExploreDto>>> Explore(double? latitude, double? longitude,
        double? radius, CancellationToken cancellationToken)
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

    [HttpGet("weather/{cragId}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(WeatherResponseDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status204NoContent)]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<WeatherResponseDto>> GetCragWeather(Guid cragId, CancellationToken cancellationToken)
    {
        var command = new GetCragWeatherCommand
        {
            CragId = cragId
        };
        var result = await mediator.Send(command, cancellationToken);
        if (result == null)
        {
            return NoContent();
        }
        return Ok(result);
    }

    [HttpPost("globe")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(ICollection<GlobeResponseDto>), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<ICollection<GlobeResponseDto>>> GetGlobe(GetGlobeCommand command,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpGet("globe/sectors/{cragId}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(ICollection<GlobeSectorResponseDto>), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<ICollection<GlobeSectorResponseDto>>> GetGlobeSectors(Guid cragId,
        CancellationToken cancellationToken)
    {
        var command = new GetGlobeSectorCommand
        {
            CragId = cragId
        };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }
}