using Microsoft.AspNetCore.Http;
using SixLabors.ImageSharp;

namespace Alpinity.Application.Helpers;

/// <summary>
/// Helper class for validating images
/// </summary>
public static class ImageValidationHelper
{
    /// <summary>
    /// Maximum pixel height (4K)
    /// </summary>
    public const int MaxPixelHeight = 4096;

    /// <summary>
    /// Maximum pixel width (4K)
    /// </summary>
    public const int MaxPixelWidth = 4096;

    /// <summary>
    /// Maximum file size in bytes (20MB)
    /// </summary>
    public const int MaxFileSizeBytes = 20 * 1024 * 1024;

    /// <summary>
    /// Validates if the file size is within allowed limits
    /// </summary>
    /// <param name="file">The file to validate</param>
    /// <param name="maxSizeBytes">Maximum file size in bytes</param>
    /// <returns>True if file size is valid, otherwise false</returns>
    public static bool ValidateFileSize(IFormFile file, int maxSizeBytes = MaxFileSizeBytes)
    {
        return file.Length <= maxSizeBytes;
    }

    /// <summary>
    /// Validates if the image resolution is within allowed limits
    /// </summary>
    /// <param name="file">The image file to validate</param>
    /// <returns>True if resolution is valid, otherwise false</returns>
    public static bool ValidateImageResolution(IFormFile file)
    {
        try
        {
            using var stream = file.OpenReadStream();
            using var image = Image.Load(stream);
            return image.Width <= MaxPixelWidth && image.Height <= MaxPixelHeight;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error validating image resolution: {ex.Message}");
            return false;
        }
    }

    /// <summary>
    /// Performs full image validation including file size and resolution
    /// </summary>
    /// <param name="file">The image file to validate</param>
    /// <param name="maxSizeBytes">Maximum file size in bytes</param>
    /// <returns>True if image passes all validations, otherwise false</returns>
    public static bool ValidateImage(IFormFile file, int maxSizeBytes = MaxFileSizeBytes)
    {
        if (file == null)
            return false;

        return ValidateFileSize(file, maxSizeBytes) && ValidateImageResolution(file);
    }
}