using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Commands.UploadPhoto;

public class UploadSectorPhotoCommandHandler(
    ISectorRepository sectorRepository,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository,
    IMapper mapper) : IRequestHandler<UploadSectorPhotoCommand>
{
    public async Task Handle(UploadSectorPhotoCommand request, CancellationToken cancellationToken)
    {
        var sector = await sectorRepository.GetSectorById(request.SectorId, cancellationToken);
        if (sector == null) throw new EntityNotFoundException("Sector not found.");

        var photoFile = mapper.Map<FileRequest>(request.Photo);

        var photoUrl = await fileRepository.UploadPrivateFileAsync(photoFile, cancellationToken);

        var photo = await photoRepository.AddImage(new Photo
        {
            Url = photoUrl
        }, cancellationToken);

        sector.Photos ??= new List<Photo>();
        sector.Photos.Add(photo);

        await sectorRepository.UpdateSector(sector, cancellationToken);
    }
}