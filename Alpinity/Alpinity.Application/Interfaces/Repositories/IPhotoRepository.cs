using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IPhotoRepository
{
    Task<Photo> AddImage(Photo photo);

    Task<ICollection<Photo>> AddImages(ICollection<Photo> photos);
}