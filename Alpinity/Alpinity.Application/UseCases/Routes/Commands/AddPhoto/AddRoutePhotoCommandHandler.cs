using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Routes.Commands.AddPhoto;

public class AddRoutePhotoCommandHandler(
    IRouteRepository routeRepository,
    IFileRepository fileRepository,
    IPhotoRepository photoRepository,
    IMapper mapper) : IRequestHandler<AddRoutePhotoCommand>
{
    public async Task Handle(AddRoutePhotoCommand request, CancellationToken cancellationToken)
    {
        var route = await routeRepository.GetRouteById(request.RouteId, cancellationToken) ?? throw new EntityNotFoundException("Route not found.");
        var photoFile = mapper.Map<FileRequest>(request.Photo);
        var linePhotoFile = mapper.Map<FileRequest>(request.LinePhoto);
        var combinedPhotoFile = mapper.Map<FileRequest>(request.CombinedPhoto);

        var photoUrl = await fileRepository.UploadPrivateFileAsync(photoFile, cancellationToken);
        var linePhotoUrl = await fileRepository.UploadPrivateFileAsync(linePhotoFile, cancellationToken);
        var combinedPhotoUrl = await fileRepository.UploadPrivateFileAsync(combinedPhotoFile, cancellationToken);

        var photo = await photoRepository.AddImage(new Photo
        {
            Url = photoUrl
        }, cancellationToken);

        var linePhoto = await photoRepository.AddImage(new Photo
        {
            Url = linePhotoUrl
        }, cancellationToken);

        var combinedPhoto = await photoRepository.AddImage(new Photo
        {
            Url = combinedPhotoUrl
        }, cancellationToken);

        var routePhoto = new RoutePhoto
        {
            RouteId = route.Id,
            ImageId = photo.Id,
            PathLineId = linePhoto.Id,
            CombinedPhotoId = combinedPhoto.Id
        };

        await routeRepository.AddPhoto(route.Id, routePhoto, cancellationToken);
    }
}