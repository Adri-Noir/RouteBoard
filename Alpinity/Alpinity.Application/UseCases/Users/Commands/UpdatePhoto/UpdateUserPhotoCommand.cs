using MediatR;
using Microsoft.AspNetCore.Http;
using System.Text.Json.Serialization;
namespace Alpinity.Application.UseCases.Users.Commands.UpdatePhoto;

public class UpdateUserPhotoCommand : IRequest
{
    [JsonIgnore]
    public Guid UserId { get; set; }
    public IFormFile Photo { get; set; }
}