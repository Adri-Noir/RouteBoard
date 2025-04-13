using System.Net.Mime;
using Alpinity.Api.ProblemDetails;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Application.UseCases.Sectors.Commands.Create;
using Alpinity.Application.UseCases.Sectors.Commands.GetCrag;
using Alpinity.Application.UseCases.Sectors.Commands.UploadPhoto;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Application.UseCases.Sectors.Get;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SectorController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(SectorDetailedDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [Consumes(MediaTypeNames.Multipart.FormData)]
    public async Task<ActionResult<SectorDetailedDto>> CreateSector([FromForm] CreateSectorCommand cragCommand,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(cragCommand, cancellationToken);

        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(SectorDetailedDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<SectorDetailedDto>> GetSector(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetSectorCommand { SectorId = id }, cancellationToken);

        return Ok(result);
    }

    [HttpGet("sectorCrag/{id:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(CragDetailedDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<CragDetailedDto>> GetSectorCrag(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetSectorCragCommand { SectorId = id }, cancellationToken);

        return Ok(result);
    }

    [HttpPost("{id:guid}/photo")]
    [Authorize]
    [Consumes(MediaTypeNames.Multipart.FormData)]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(CragDetailedDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult> UploadSectorPhoto(Guid id, UploadSectorPhotoCommand command, CancellationToken cancellationToken)
    {
        command.SectorId = id;
        await mediator.Send(command, cancellationToken);
        return Ok();
    }
}