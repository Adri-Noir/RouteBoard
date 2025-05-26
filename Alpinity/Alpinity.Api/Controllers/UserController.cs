using System.Net.Mime;
using Alpinity.Application.Interfaces;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Application.UseCases.SearchHistory.Commands.GetUserSearchHistory;
using Alpinity.Application.UseCases.Search.Dtos;
using Alpinity.Application.UseCases.Users.Commands.GetUserProfile;
using Alpinity.Application.UseCases.Users.Commands.LogAscent;
using Alpinity.Application.UseCases.Users.Commands.RecentlyAscendedRoutes;
using Alpinity.Application.UseCases.Users.Commands.UpdatePhoto;
using Alpinity.Application.UseCases.Users.Commands.GetAllUsers;
using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;
using Alpinity.Api.ProblemDetails;

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
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(UserProfileDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult> LogAscent(LogAscentCommand command, CancellationToken cancellationToken)
    {
        command.UserId = (Guid)authenticationContext.GetUserId()!;

        await mediator.Send(command, cancellationToken);
        return Ok();
    }

    [HttpGet("searchHistory")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(ICollection<SearchResultDto>), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
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
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(ICollection<RecentlyAscendedRouteDto>), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
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
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(UserProfileDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<UserProfileDto>> GetUserProfile(Guid profileUserId, CancellationToken cancellationToken = default)
    {
        var command = new GetUserProfileCommand
        {
            ProfileUserId = profileUserId
        };

        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpPut("photo")]
    [Authorize]
    [Consumes(MediaTypeNames.Multipart.FormData)]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(UserProfileDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult> UpdateUserPhoto([FromForm] UpdateUserPhotoCommand command, CancellationToken cancellationToken)
    {
        command.UserId = (Guid)authenticationContext.GetUserId()!;
        await mediator.Send(command, cancellationToken);
        return Ok();
    }

    [HttpGet("all")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(PaginatedUsersDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status403Forbidden, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<PaginatedUsersDto>> GetAllUsers(
        [FromQuery] int page = 0,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? search = null,
        CancellationToken cancellationToken = default)
    {
        var command = new GetAllUsersCommand
        {
            Page = page,
            PageSize = pageSize,
            Search = search
        };
        var result = await mediator.Send(command, cancellationToken);
        return Ok(result);
    }
}
