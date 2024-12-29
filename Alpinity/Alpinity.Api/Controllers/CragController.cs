using System.Net.Mime;
using Alpinity.Application.UseCases.Crags.Commands.Create;
using Alpinity.Application.UseCases.Crags.Commands.Get;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Domain.Entities;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CragController(IMediator mediator) : ControllerBase
{
     [HttpGet("{id:guid}")]
     [Produces(MediaTypeNames.Application.Json)]
     public async Task<ActionResult<CragDetailedDto>> GetCrag(Guid id, CancellationToken cancellationToken)
     {
          var result = await mediator.Send(new GetCragCommand { CragId = id}, cancellationToken);
          
          return Ok(result);
     }
     
     [HttpPost]
     [Produces(MediaTypeNames.Application.Json)]
     public async Task<ActionResult<CragDetailedDto>> CreateCrag(CreateCragCommand cragCommand, CancellationToken cancellationToken)
     {
          var result = await mediator.Send(cragCommand, cancellationToken);
          
          return Ok(result);
     }
}