using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;

namespace Alpinity.Infrastructure.Repositories;

public class AzureFileRepository : IFileRepository
{
    private readonly BlobContainerClient _publicContainerClient;

    public AzureFileRepository(string connectionString)
    {
        _publicContainerClient = new BlobContainerClient(connectionString, "publicdata");
        _publicContainerClient.CreateIfNotExists();

        if (Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") == "Development")
            _publicContainerClient.SetAccessPolicy(PublicAccessType.Blob);
    }

    public async Task<string> UploadPublicFileAsync(FileRequest request, CancellationToken cancellationToken)
    {
        var blobClient = _publicContainerClient.GetBlockBlobClient(request.FileName);
        await blobClient.UploadAsync(
            request.Content,
            new BlobHttpHeaders
            {
                ContentType = request.ContentType
            },
            cancellationToken: cancellationToken);

        return blobClient.Uri.ToString();
    }
}