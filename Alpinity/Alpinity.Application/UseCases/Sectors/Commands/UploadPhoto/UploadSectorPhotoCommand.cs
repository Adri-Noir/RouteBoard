using Alpinity.Application.Request;
using MediatR;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.UseCases.Sectors.Commands.UploadPhoto;

public class UploadSectorPhotoCommand : IRequest
{
    public Guid SectorId { get; set; }
    public IFormFile Photo { get; set; }
}