using System.Net.Mime;
using Alpinity.Api.ProblemDetails;
using Alpinity.Application.UseCases.Search.Commands.Query;
using Alpinity.Application.UseCases.Search.Dtos;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SearchController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(ICollection<SearchResultDto>), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [Consumes(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<ICollection<SearchResultDto>>> Search(SearchQueryCommand command,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(command, cancellationToken);

        return Ok(result);
    }
}