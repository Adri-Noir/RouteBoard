using Alpinity.Application.Request;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IFileRepository
{
    Task<string> UploadPublicFileAsync(FileRequest request, CancellationToken cancellationToken);
}