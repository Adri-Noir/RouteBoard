using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;

namespace Alpinity.Infrastructure.Repositories;

public class PhotoRepository(ApplicationDbContext dbContext) : IPhotoRepository
{
    public async Task<Photo> AddImage(Photo photo, CancellationToken cancellationToken = default)
    {
        dbContext.Photos.Add(photo);
        await dbContext.SaveChangesAsync(cancellationToken);
        return photo;
    }

    public async Task<ICollection<Photo>> AddImages(ICollection<Photo> photos, CancellationToken cancellationToken = default)
    {
        dbContext.Photos.AddRange(photos);
        await dbContext.SaveChangesAsync(cancellationToken);
        return photos;
    }
}