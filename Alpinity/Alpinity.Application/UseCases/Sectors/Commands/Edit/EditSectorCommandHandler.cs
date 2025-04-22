using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;
using NetTopologySuite.Geometries;
using Alpinity.Application.Helpers;
using Alpinity.Application.Interfaces;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Sectors.Commands.Edit;

public class EditSectorCommandHandler(
    ICragRepository cragRepository,
    ISectorRepository sectorRepository,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository,
    IMapper mapper,
    IAuthenticationContext authenticationContext) : IRequestHandler<EditSectorCommand, SectorDetailedDto>
{
    public async Task<SectorDetailedDto> Handle(EditSectorCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();
        var sector = await sectorRepository.GetSectorById(request.Id, cancellationToken) ?? throw new EntityNotFoundException("Sector not found.");
        if (userRole != UserRole.Admin)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await sectorRepository.IsUserCreatorOfSector(request.Id, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to edit this sector.");
            }
        }

        var locationIsChanged = false;

        if (request.Name != null)
            sector.Name = request.Name;
        if (request.Description != null)
            sector.Description = request.Description;
        if (request.Location != null)
        {
            sector.Location = mapper.Map<Point>(request.Location);
            locationIsChanged = true;
        }

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

        if (locationIsChanged)
        {
            var crag = await cragRepository.GetCragWithSectors(sector.CragId, cancellationToken)
                ?? throw new EntityNotFoundException("Crag not found.");

            crag.Location = LocationCalculationHelper.CalculateAverageLocation(crag.Sectors);
            await cragRepository.UpdateCrag(crag, cancellationToken);
        }

        return mapper.Map<SectorDetailedDto>(sector);
    }
}