using Alpinity.Application.UseCases.Search.Dtos;
using Alpinity.Application.UseCases.Search.Get;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SearchController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult<SearchResultDto>> Search(GetSearchCommand searchCommand, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(searchCommand, cancellationToken);
        
        return Ok(result);
    }
}