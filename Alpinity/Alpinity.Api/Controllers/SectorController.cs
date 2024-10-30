using Alpinity.Application.UseCases.Sectors.Create;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Application.UseCases.Sectors.Get;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Alpinity.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SectorController(IMediator mediator): ControllerBase
{
     
    [HttpPost]
    public async Task<ActionResult<SectorDetailedDto>> CreateSector(CreateSectorCommand cragCommand, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(cragCommand, cancellationToken);
          
        return Ok(result);
    }
    
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<SectorDetailedDto>> GetSector(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetSectorCommand { SectorId = id}, cancellationToken);
        
        return Ok(result);
    }
}