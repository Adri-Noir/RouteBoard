using System.Net.Mime;
using Alpinity.Application.Interfaces;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Application.UseCases.SearchHistory.Commands.GetUserSearchHistory;
using Alpinity.Application.UseCases.Search.Dtos;    
using Alpinity.Application.UseCases.Users.Commands.GetUserProfile;
using Alpinity.Application.UseCases.Users.Commands.LogAscent;
using Alpinity.Application.UseCases.Users.Commands.RecentlyAscendedRoutes;
using Alpinity.Application.UseCases.Users.Dtos;
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
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> LogAscent(LogAscentCommand command, CancellationToken cancellationToken)
    {
        command.UserId = (Guid)authenticationContext.GetUserId()!;
        
        await mediator.Send(command, cancellationToken);
        return Ok();
    }
    
    [HttpGet("searchHistory")]
    [Authorize]
    [Produces(MediaTypeNames.Application.Json)] 
    [ProducesResponseType(typeof(ICollection<SearchResultDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<ICollection<SearchResultDto>>> GetSearchHistory([FromQuery] int count = 10, CancellationToken cancellationToken = default)
    {
        var command = new GetUserSearchHistoryCommand
        {
            SearchingUserId = (Guid)authenticationContext.GetUserId()!,
            Count = count
        };
        
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpGet("recentlyAscendedRoutes")]
    [Authorize]
    [Produces(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<ICollection<RecentlyAscendedRouteDto>>> GetRecentlyAscendedRoutes(CancellationToken cancellationToken = default)
    {
        var command = new RecentlyAscendedRoutesCommand
        {
            UserId = (Guid)authenticationContext.GetUserId()!
        };
        
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpGet("user/{profileUserId}")]
    [Produces(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UserProfileDto>> GetUserProfile(Guid profileUserId, CancellationToken cancellationToken = default)
    {
        var command = new GetUserProfileCommand
        {
            ProfileUserId = profileUserId
        };
        
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }
}
