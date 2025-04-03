using System.Net.Mime;
using Alpinity.Api.ProblemDetails;
using Alpinity.Application.UseCases.Crags.Commands.Create;
using Alpinity.Application.UseCases.Crags.Commands.Get;
using Alpinity.Application.UseCases.Crags.Commands.UploadPhoto;
using Alpinity.Application.UseCases.Crags.Dtos;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CragController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id:guid}")]
    [Authorize]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(CragDetailedDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<CragDetailedDto>> GetCrag(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetCragCommand { CragId = id }, cancellationToken);

        return Ok(result);
    }

    [HttpPost]
    [Authorize]
    [Consumes(MediaTypeNames.Application.Json)]
    [SwaggerResponse(StatusCodes.Status200OK, Type = typeof(CragDetailedDto), ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult<CragDetailedDto>> CreateCrag(CreateCragCommand cragCommand,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(cragCommand, cancellationToken);

        return Ok(result);
    }

    [HttpPost("{id:guid}/photo")]
    [Authorize]
    [Consumes(MediaTypeNames.Multipart.FormData)]
    [SwaggerResponse(StatusCodes.Status200OK, ContentTypes = new[] { "application/json" })]
    [SwaggerResponse(StatusCodes.Status400BadRequest, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status401Unauthorized, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    [SwaggerResponse(StatusCodes.Status404NotFound, Type = typeof(CustomProblemDetailsResponse), ContentTypes = new[] { "application/problem+json" })]
    public async Task<ActionResult> UploadCragPhoto(Guid id, UploadCragPhotoCommand command, CancellationToken cancellationToken)
    {
        command.CragId = id;
        await mediator.Send(command, cancellationToken);
        return Ok();
    }
}