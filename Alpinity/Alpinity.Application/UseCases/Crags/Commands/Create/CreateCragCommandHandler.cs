using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;
using MediatR;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommandHandler(ICragRepository repository, IMapper mapper) : IRequestHandler<CreateCragCommand, CragDetailedDto>
{
    public async Task<CragDetailedDto> Handle(CreateCragCommand request, CancellationToken cancellationToken)
    {
        var point = mapper.Map<Point>(request.Location);
        var crag = new Crag
        {
            Name = request.Name,
            Description = request.Description,
            Location = point,
        };  

        await repository.CreateCrag(crag);

        return mapper.Map<CragDetailedDto>(crag); 
    }
}