using Microsoft.AspNetCore.Http;
using SixLabors.ImageSharp;

namespace Alpinity.Application.Helpers;

/// <summary>
///     Helper class for validating images
/// </summary>
public static class ImageValidationHelper
{
    /// <summary>
    ///     Maximum pixel height (4K)
    /// </summary>
    public const int MaxPixelHeight = 4096;

    /// <summary>
    ///     Maximum pixel width (4K)
    /// </summary>
    public const int MaxPixelWidth = 4096;

    /// <summary>
    ///     Maximum file size in bytes (5MB - adjusted based on validator)
    /// </summary>
    public const int MaxFileSizeBytes = 15 * 1024 * 1024;

    /// <summary>
    /// Allowed image file extensions.
    /// </summary>
    public static readonly string[] AllowedImageExtensions = [".jpg", ".jpeg", ".png"];

    /// <summary>
    /// Allowed image content types.
    /// </summary>
    public static readonly string[] AllowedImageContentTypes = ["image/jpeg", "image/png"];

    /// <summary>
    ///     Validates if the file size is within allowed limits
    /// </summary>
    /// <param name="file">The file to validate</param>
    /// <param name="maxSizeBytes">Maximum file size in bytes</param>
    /// <returns>True if file size is valid, otherwise false</returns>
    public static bool ValidateFileSize(IFormFile file, int maxSizeBytes = MaxFileSizeBytes)
    {
        return file != null && file.Length <= maxSizeBytes && file.Length > 0;
    }

    /// <summary>
    /// Validates if the file has an allowed extension.
    /// </summary>
    /// <param name="fileName">The file name to validate.</param>
    /// <returns>True if the extension is allowed, otherwise false.</returns>
    public static bool HasAllowedExtension(string fileName)
    {
        if (string.IsNullOrEmpty(fileName))
            return false;
        var extension = Path.GetExtension(fileName)?.ToLowerInvariant();
        return !string.IsNullOrEmpty(extension) && AllowedImageExtensions.Contains(extension);
    }

    /// <summary>
    /// Validates if the file has an allowed content type.
    /// </summary>
    /// <param name="contentType">The content type to validate.</param>
    /// <returns>True if the content type is allowed, otherwise false.</returns>
    public static bool HasAllowedContentType(string contentType)
    {
        return !string.IsNullOrEmpty(contentType) && AllowedImageContentTypes.Contains(contentType.ToLowerInvariant());
    }

    /// <summary>
    ///     Validates if the image resolution is within allowed limits
    /// </summary>
    /// <param name="file">The image file to validate</param>
    /// <returns>True if resolution is valid, otherwise false</returns>
    public static bool ValidateImageResolution(IFormFile file)
    {
        if (file == null) return false;
        try
        {
            // Ensure the stream is properly reset if needed by the image loading library
            // Or ensure the check happens before other stream reads.
            file.OpenReadStream().Position = 0; // Reset stream position
            using var stream = file.OpenReadStream();
            using var image = Image.Load(stream);
            return image.Width <= MaxPixelWidth && image.Height <= MaxPixelHeight && image.Width > 0 && image.Height > 0;
        }
        catch
        {
            // Log exception details here
            return false;
        }
    }

    /// <summary>
    ///     Performs comprehensive image validation including file size, extension, content type, and resolution.
    /// </summary>
    /// <param name="file">The image file to validate</param>
    /// <param name="maxSizeBytes">Maximum file size in bytes</param>
    /// <returns>True if image passes all validations, otherwise false</returns>
    public static bool ValidateImage(IFormFile file, int maxSizeBytes = MaxFileSizeBytes)
    {
        if (file == null)
            return false;

        // Order checks from cheapest to most expensive
        return ValidateFileSize(file, maxSizeBytes)
               && HasAllowedExtension(file.FileName)
               && HasAllowedContentType(file.ContentType)
               && ValidateImageResolution(file);
    }

    /// <summary>
    ///     Validates if two images have the same resolution
    /// </summary>
    /// <param name="file1">The first image file</param>
    /// <param name="file2">The second image file</param>
    /// <returns>True if both images have the same resolution, otherwise false</returns>
    public static bool ValidateImagesHaveSameResolution(IFormFile file1, IFormFile file2)
    {
        try
        {
            using var stream1 = file1.OpenReadStream();
            using var stream2 = file2.OpenReadStream();
            using var image1 = Image.Load(stream1);
            using var image2 = Image.Load(stream2);
            return image1.Width == image2.Width && image1.Height == image2.Height;
        }
        catch
        {
            return false;
        }
    }
}