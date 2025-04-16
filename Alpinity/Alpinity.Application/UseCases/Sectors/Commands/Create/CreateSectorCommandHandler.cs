using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.UseCases.Sectors.Commands.Create;

public class CreateSectorCommandHandler(
    ISectorRepository sectorRepository,
    ICragRepository cragRepository,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository,
    IMapper mapper) : IRequestHandler<CreateSectorCommand, SectorDetailedDto>
{
    public async Task<SectorDetailedDto> Handle(CreateSectorCommand request, CancellationToken cancellationToken)
    {
        var cragExists = await cragRepository.CragExists(request.CragId, cancellationToken);
        if (!cragExists) throw new EntityNotFoundException("Crag not found.");

        var point = mapper.Map<Point>(request.Location);

        var sector = new Sector
        {
            Name = request.Name,
            Description = request.Description,
            CragId = request.CragId,
            Location = point,
            Photos = new List<Photo>()
        };

        if (request.Photos != null && request.Photos.Any())
        {
            foreach (var photoFile in request.Photos)
            {
                var fileRequest = mapper.Map<FileRequest>(photoFile);
                var photoUrl = await fileRepository.UploadPrivateFileAsync(fileRequest, cancellationToken);
                var photo = await photoRepository.AddImage(new Photo { Url = photoUrl }, cancellationToken);
                sector.Photos.Add(photo);
            }
        }

        await sectorRepository.CreateSector(sector, cancellationToken);

        // If the sector has a location, update the crag's location to the average of all sector locations
        if (sector.Location != null)
        {
            var crag = await cragRepository.GetCragWithSectors(sector.CragId, cancellationToken) ?? throw new EntityNotFoundException("Crag not found.");

            // Calculate average latitude and longitude of all sector locations
            var sectorsWithLocations = crag.Sectors?
                .Where(s => s.Location != null)
                .ToList();

            if (sectorsWithLocations != null && sectorsWithLocations.Any())
            {
                double avgLatitude = sectorsWithLocations.Average(s => s.Location!.Y);
                double avgLongitude = sectorsWithLocations.Average(s => s.Location!.X);

                crag.Location = new Point(avgLongitude, avgLatitude) { SRID = 4326 };
            }
            else
            {
                crag.Location = null;
            }

            await cragRepository.UpdateCrag(crag, cancellationToken);
        }

        return mapper.Map<SectorDetailedDto>(sector);
    }
}