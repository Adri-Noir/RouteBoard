using System.Net.Mime;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Application.UseCases.Sectors.Commands.Create;
using Alpinity.Application.UseCases.Sectors.Commands.GetCrag;
using Alpinity.Application.UseCases.Sectors.Commands.UploadPhoto;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Application.UseCases.Sectors.Get;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SectorController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status404NotFound)]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<SectorDetailedDto>> CreateSector(CreateSectorCommand cragCommand,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(cragCommand, cancellationToken);

        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status404NotFound)]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<SectorDetailedDto>> GetSector(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetSectorCommand { SectorId = id }, cancellationToken);

        return Ok(result);
    }

    [HttpGet("sectorCrag/{id:guid}")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status404NotFound)]
    [Produces(MediaTypeNames.Application.Json)]
    public async Task<ActionResult<CragDetailedDto>> GetSectorCrag(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetSectorCragCommand { SectorId = id }, cancellationToken);

        return Ok(result);
    }

    [HttpPost("{id:guid}/photo")]
    [Authorize]
    [Consumes(MediaTypeNames.Multipart.FormData)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(Microsoft.AspNetCore.Mvc.ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> UploadSectorPhoto(Guid id, [FromForm] UploadSectorPhotoCommand command, CancellationToken cancellationToken)
    {
        command.SectorId = id;
        await mediator.Send(command, cancellationToken);
        return Ok();
    }
}