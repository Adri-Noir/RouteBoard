using System.Net.Mime;
using Alpinity.Api.ProblemDetails;
using Alpinity.Application.Interfaces;
using Alpinity.Application.UseCases.Users.Commands.Login;
using Alpinity.Application.UseCases.Users.Commands.Me;
using Alpinity.Application.UseCases.Users.Commands.Register;
using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthenticationController(
    IMediator mediator,
    IAuthenticationContext authenticationContext) : ControllerBase
{
    [HttpPost("login")]
    [Consumes(MediaTypeNames.Application.Json)]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(LoggedInUserDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<LoggedInUserDto>> Login(LoginCommand command, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(command, cancellationToken);

        return Ok(result);
    }

    [HttpPost("register")]
    [Consumes(MediaTypeNames.Multipart.FormData)]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(LoggedInUserDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status409Conflict, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<LoggedInUserDto>> Register(
        [FromForm] RegisterCommand command,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(command, cancellationToken);

        return Ok(result);
    }

    [HttpPost("authenticated")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [Consumes(MediaTypeNames.Application.Json)]
    public ActionResult AuthCheck()
    {
        return Ok();
    }

    [HttpPost("me")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(LoggedInUserDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [Consumes(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<LoggedInUserDto>> GetUserFromJwt(
        CancellationToken cancellationToken)
    {
        var results = await mediator.Send(
            new MeCommand
            { UserId = (Guid)authenticationContext.GetUserId()!, Token = authenticationContext.GetJwtToken() },
            cancellationToken);

        return Ok(results);
    }
}