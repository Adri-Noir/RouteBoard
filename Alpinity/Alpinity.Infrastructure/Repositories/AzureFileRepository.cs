using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Request;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;
using Azure.Storage.Sas;

namespace Alpinity.Infrastructure.Repositories;

public class AzureFileRepository : IFileRepository
{
    private readonly BlobContainerClient _publicContainerClient;
    private readonly BlobContainerClient _privateContainerClient;
    private readonly string _accountName;
    private readonly string _accountKey;

    public AzureFileRepository(string connectionString)
    {
        // Extract account name and key from the connection string for SAS token generation
        _accountName = ExtractValueFromConnectionString(connectionString, "AccountName");
        _accountKey = ExtractValueFromConnectionString(connectionString, "AccountKey");

        // Public container setup
        _publicContainerClient = new BlobContainerClient(connectionString, "publicdata");
        _publicContainerClient.CreateIfNotExists();
        _publicContainerClient.SetAccessPolicy(PublicAccessType.None);

        // Private container setup - always private
        _privateContainerClient = new BlobContainerClient(connectionString, "privatedata");
        _privateContainerClient.CreateIfNotExists();
        _privateContainerClient.SetAccessPolicy(PublicAccessType.None);
    }

    public async Task<string> UploadPublicFileAsync(FileRequest request, CancellationToken cancellationToken)
    {
        var fileName = Guid.NewGuid().ToString();
        var blobClient = _publicContainerClient.GetBlockBlobClient(fileName);
        await blobClient.UploadAsync(
            request.Content,
            new BlobHttpHeaders
            {
                ContentType = request.ContentType
            },
            cancellationToken: cancellationToken);

        return blobClient.Uri.ToString();
    }

    public async Task<string> UploadPrivateFileAsync(FileRequest request, CancellationToken cancellationToken)
    {
        var fileName = Guid.NewGuid().ToString();
        var blobClient = _privateContainerClient.GetBlockBlobClient(fileName);
        await blobClient.UploadAsync(
            request.Content,
            new BlobHttpHeaders
            {
                ContentType = request.ContentType
            },
            cancellationToken: cancellationToken);

        return fileName;
    }

    public string GetTemporaryUrl(string blobName, TimeSpan validity)
    {
        var blobClient = _privateContainerClient.GetBlobClient(blobName);

        // Create SAS token with specified expiration
        var sasBuilder = new BlobSasBuilder
        {
            BlobContainerName = _privateContainerClient.Name,
            BlobName = blobName,
            Resource = "b", // b for blob
            ExpiresOn = DateTimeOffset.UtcNow.Add(validity)
        };

        // Set permissions to read only
        sasBuilder.SetPermissions(BlobSasPermissions.Read);

        // Generate the SAS token
        var credential = new Azure.Storage.StorageSharedKeyCredential(_accountName, _accountKey);
        var sasToken = sasBuilder.ToSasQueryParameters(credential).ToString();

        // Return the full URL with SAS token
        return $"{blobClient.Uri}?{sasToken}";
    }

    // Helper method to extract values from Azure connection string
    private string ExtractValueFromConnectionString(string connectionString, string key)
    {
        var keyValuePair = connectionString
            .Split(';')
            .FirstOrDefault(p => p.StartsWith($"{key}="));

        if (keyValuePair == null)
            throw new ArgumentException($"{key} not found in connection string");

        return keyValuePair.Substring($"{key}=".Length);
    }
}