using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommandHandler(
    ICragRepository repository,
    IMapper mapper,
    IAuthenticationContext authenticationContext,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository
    ) : IRequestHandler<CreateCragCommand, CragDetailedDto>
{
    public async Task<CragDetailedDto> Handle(CreateCragCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();

        if (userRole != UserRole.Admin && userRole != UserRole.Creator)
        {
            throw new UnAuthorizedAccessException("You are not authorized to create a crag.");
        }

        var crag = new Crag
        {
            Name = request.Name,
            Description = request.Description,
            Photos = new List<Photo>()
        };

        if (request.Photos != null && request.Photos.Any())
        {
            foreach (var photoFile in request.Photos)
            {
                var fileRequest = mapper.Map<FileRequest>(photoFile);
                var photoUrl = await fileRepository.UploadPrivateFileAsync(fileRequest, cancellationToken);
                var photo = await photoRepository.AddImage(new Photo { Url = photoUrl }, cancellationToken);
                crag.Photos.Add(photo);
            }
        }

        await repository.CreateCrag(crag, cancellationToken);

        var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
        if (userRole == UserRole.Creator)
        {
            await repository.AddCragCreator(crag.Id, userId, cancellationToken);
        }

        return mapper.Map<CragDetailedDto>(crag);
    }
}