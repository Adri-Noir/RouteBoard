using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Commands.Create;

public class CreateSectorCommandHandler(
    ISectorRepository sectorRepository,
    ICragRepository cragRepository,
    IMapper mapper,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository) : IRequestHandler<CreateSectorCommand, SectorDetailedDto>
{
    public async Task<SectorDetailedDto> Handle(CreateSectorCommand request, CancellationToken cancellationToken)
    {
        var crag = await cragRepository.GetCragById(request.CragId, cancellationToken);
        if (crag == null) throw new EntityNotFoundException("Crag not found.");

        var sector = new Sector
        {
            Name = request.Name,
            Description = request.Description,
            CragId = request.CragId
        };

        await sectorRepository.CreateSector(sector, cancellationToken);

        var photos = new List<Photo>();

        foreach (var photo in request.Photos)
        {
            var file = mapper.Map<FileRequest>(photo);
            var url = await fileRepository.UploadPublicFileAsync(file, cancellationToken);

            var photoEntity = new Photo
            {
                Url = url,
                SectorId = sector.Id
            };

            photos.Add(photoEntity);
            await photoRepository.AddImage(photoEntity, cancellationToken);
        }

        await sectorRepository.AddPhotos(sector.Id, photos, cancellationToken);

        return mapper.Map<SectorDetailedDto>(sector);
    }
}