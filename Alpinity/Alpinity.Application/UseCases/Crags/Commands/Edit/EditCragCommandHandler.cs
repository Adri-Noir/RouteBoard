using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.Edit;

public class EditCragCommandHandler(
    ICragRepository repository,
    IMapper mapper,
    IAuthenticationContext authenticationContext,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository
    ) : IRequestHandler<EditCragCommand, CragDetailedDto>
{
    public async Task<CragDetailedDto> Handle(EditCragCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();

        var crag = await repository.GetCragById(request.Id, cancellationToken) ?? throw new EntityNotFoundException("Crag not found.");

        if (userRole != UserRole.Admin)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await repository.IsUserCreatorOfCrag(request.Id, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to edit this crag.");
            }
        }

        if (request.Name != null)
            crag.Name = request.Name;
        if (request.Description != null)
            crag.Description = request.Description;
        if (request.LocationName != null)
            crag.LocationName = request.LocationName;

        if (request.PhotosToRemove != null && request.PhotosToRemove.Any() && crag.Photos != null)
        {
            crag.Photos = crag.Photos.Where(p => !request.PhotosToRemove.Contains(p.Id)).ToList();
        }

        if (request.Photos != null && request.Photos.Any())
        {
            crag.Photos = new List<Photo>();
            foreach (var photoFile in request.Photos)
            {
                var fileRequest = mapper.Map<FileRequest>(photoFile);
                var photoUrl = await fileRepository.UploadPrivateFileAsync(fileRequest, cancellationToken);
                var photo = await photoRepository.AddImage(new Photo { Url = photoUrl }, cancellationToken);
                crag.Photos.Add(photo);
            }
        }

        await repository.UpdateCrag(crag, cancellationToken);
        return mapper.Map<CragDetailedDto>(crag);
    }
}