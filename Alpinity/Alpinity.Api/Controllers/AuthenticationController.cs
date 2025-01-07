using System.Net.Mime;
using Alpinity.Application.Interfaces;
using Alpinity.Application.UseCases.Users.Commands.Login;
using Alpinity.Application.UseCases.Users.Commands.Me;
using Alpinity.Application.UseCases.Users.Commands.Register;
using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthenticationController(
    IMediator mediator,
    IAuthenticationContext authenticationContext) : ControllerBase
{
    [HttpPost("login")]
    [Consumes(MediaTypeNames.Application.Json)]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<LoggedInUserDto>> Login(LoginCommand command, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(command, cancellationToken);

        return Ok(result);
    }

    [HttpPost("register")]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<LoggedInUserDto>> Register(RegisterCommand command,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(command, cancellationToken);

        return Ok(result);
    }

    [HttpPost("authenticated")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [Produces(MediaTypeNames.Application.ProblemJson)]
    public ActionResult AuthCheck()
    {
        return Ok();
    }

    [HttpPost("me")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<LoggedInUserDto>> GetUserFromJwt(
        CancellationToken cancellationToken)
    {
        var results = await mediator.Send(
            new MeCommand
                { userId = (Guid)authenticationContext.GetUserId()!, token = authenticationContext.GetJwtToken() },
            cancellationToken);

        return Ok(results);
    }
}