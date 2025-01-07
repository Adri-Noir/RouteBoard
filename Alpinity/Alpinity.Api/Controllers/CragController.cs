using System.Net.Mime;
using Alpinity.Application.UseCases.Crags.Commands.Create;
using Alpinity.Application.UseCases.Crags.Commands.Get;
using Alpinity.Application.UseCases.Crags.Dtos;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CragController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id:guid}")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<CragDetailedDto>> GetCrag(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetCragCommand { CragId = id }, cancellationToken);

        return Ok(result);
    }

    [HttpPost]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [Consumes(MediaTypeNames.Application.Json)]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<CragDetailedDto>> CreateCrag(CreateCragCommand cragCommand,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(cragCommand, cancellationToken);

        return Ok(result);
    }
}