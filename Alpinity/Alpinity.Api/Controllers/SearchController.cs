using System.Net.Mime;
using Alpinity.Application.UseCases.Search.Dtos;
using Alpinity.Application.UseCases.Search.Commands.Query;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SearchController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<SearchResultDto>> Search(SearchQueryCommand command, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(command, cancellationToken);
        
        return Ok(result);
    }
}