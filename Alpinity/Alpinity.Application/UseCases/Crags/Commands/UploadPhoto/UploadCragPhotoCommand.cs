using Alpinity.Application.Request;
using MediatR;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.UseCases.Crags.Commands.UploadPhoto;

public class UploadCragPhotoCommand : IRequest
{
    public Guid CragId { get; set; }
    public IFormFile Photo { get; set; }
}