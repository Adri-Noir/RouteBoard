using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.UseCases.Sectors.Commands.Edit;

public class EditSectorCommandHandler(
    ISectorRepository sectorRepository,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository,
    IMapper mapper) : IRequestHandler<EditSectorCommand, SectorDetailedDto>
{
    public async Task<SectorDetailedDto> Handle(EditSectorCommand request, CancellationToken cancellationToken)
    {
        var sector = await sectorRepository.GetSectorById(request.Id, cancellationToken) ?? throw new EntityNotFoundException("Sector not found.");

        if (request.Name != null)
            sector.Name = request.Name;
        if (request.Description != null)
            sector.Description = request.Description;
        if (request.Location != null)
            sector.Location = mapper.Map<Point>(request.Location);

        if (request.PhotosToRemove != null && request.PhotosToRemove.Any() && sector.Photos != null)
        {
            sector.Photos = sector.Photos.Where(p => !request.PhotosToRemove.Contains(p.Id)).ToList();
        }

        if (request.Photos != null && request.Photos.Any())
        {
            sector.Photos ??= new List<Photo>();
            foreach (var photoFile in request.Photos)
            {
                var fileRequest = mapper.Map<FileRequest>(photoFile);
                var photoUrl = await fileRepository.UploadPrivateFileAsync(fileRequest, cancellationToken);
                var photo = await photoRepository.AddImage(new Photo { Url = photoUrl }, cancellationToken);
                sector.Photos.Add(photo);
            }
        }

        await sectorRepository.UpdateSector(sector, cancellationToken);
        return mapper.Map<SectorDetailedDto>(sector);
    }
}