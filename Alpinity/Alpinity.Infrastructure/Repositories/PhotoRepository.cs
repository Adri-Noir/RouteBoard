using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Infrastructure.Persistence;

namespace Alpinity.Infrastructure.Repositories;

public class PhotoRepository(ApplicationDbContext dbContext) : IPhotoRepository
{
    public async Task<Photo> AddImage(Photo photo)
    {
        dbContext.Photos.Add(photo);
        await dbContext.SaveChangesAsync();
        return photo;
    }

    public async Task<ICollection<Photo>> AddImages(ICollection<Photo> photos)
    {
        dbContext.Photos.AddRange(photos);
        await dbContext.SaveChangesAsync();
        return photos;
    }
}