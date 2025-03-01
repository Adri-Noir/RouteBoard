using System.Net.Mime;
using Alpinity.Application.Interfaces;
using Alpinity.Application.UseCases.Users.Commands.LogAscent;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserController(
    IMediator mediator,
    IAuthenticationContext authenticationContext) : ControllerBase
{
    [HttpPost("logAscent")]
    [Authorize]
    [Consumes(MediaTypeNames.Application.Json)]
    [Produces(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult> LogAscent(LogAscentCommand command, CancellationToken cancellationToken)
    {
        command.UserId = (Guid)authenticationContext.GetUserId()!;
        
        await mediator.Send(command, cancellationToken);
        return Ok();
    }
}
