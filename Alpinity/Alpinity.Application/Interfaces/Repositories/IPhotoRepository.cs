using Alpinity.Domain.Entities;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IPhotoRepository
{
    Task<Photo> AddImage(Photo photo, CancellationToken cancellationToken = default);

    Task<ICollection<Photo>> AddImages(ICollection<Photo> photos, CancellationToken cancellationToken = default);
}