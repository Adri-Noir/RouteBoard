using Alpinity.Application.Request;

namespace Alpinity.Application.Interfaces.Repositories;

public interface IFileRepository
{
    Task<string> UploadPublicFileAsync(FileRequest request, CancellationToken cancellationToken = default);
    Task<string> UploadPrivateFileAsync(FileRequest request, CancellationToken cancellationToken = default);
    string GetTemporaryUrl(string blobName, TimeSpan validity);
}