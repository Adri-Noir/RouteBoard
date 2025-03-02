using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;
using MediatR;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommandHandler(ICragRepository repository, IMapper mapper, ILocationInformationService locationInformationService) : IRequestHandler<CreateCragCommand, CragDetailedDto>
{
    public async Task<CragDetailedDto> Handle(CreateCragCommand request, CancellationToken cancellationToken)
    {
        var locationInformation = await locationInformationService.GetLocationInformationFromCoordinates(request.Location.Latitude, request.Location.Longitude);
        var locationName = locationInformationService.GetLocationNameFromLocationInformation(locationInformation);
        var point = mapper.Map<Point>(request.Location);
        var crag = new Crag
        {
            Name = request.Name,
            Description = request.Description,
            Location = point,
            LocationName = locationName
        };  

        await repository.CreateCrag(crag);

        return mapper.Map<CragDetailedDto>(crag); 
    }
}