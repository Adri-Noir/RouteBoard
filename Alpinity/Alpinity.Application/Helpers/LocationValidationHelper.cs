namespace Alpinity.Application.Helpers;
using Alpinity.Application.Dtos;

/// <summary>
/// Helper class for validating location data.
/// </summary>
public static class LocationValidationHelper
{
    /// <summary>
    /// Minimum valid latitude.
    /// </summary>
    public const double MinLatitude = -90.0;

    /// <summary>
    /// Maximum valid latitude.
    /// </summary>
    public const double MaxLatitude = 90.0;

    /// <summary>
    /// Minimum valid longitude.
    /// </summary>
    public const double MinLongitude = -180.0;

    /// <summary>
    /// Maximum valid longitude.
    /// </summary>
    public const double MaxLongitude = 180.0;

    /// <summary>
    /// Validates if the latitude is within the allowed range [-90, 90].
    /// </summary>
    /// <param name="latitude">The latitude to validate.</param>
    /// <returns>True if the latitude is valid, otherwise false.</returns>
    public static bool ValidateLatitude(double latitude)
    {
        return latitude >= MinLatitude && latitude <= MaxLatitude;
    }

    /// <summary>
    /// Validates if the longitude is within the allowed range [-180, 180].
    /// </summary>
    /// <param name="longitude">The longitude to validate.</param>
    /// <returns>True if the longitude is valid, otherwise false.</returns>
    public static bool ValidateLongitude(double longitude)
    {
        return longitude >= MinLongitude && longitude <= MaxLongitude;
    }

    /// <summary>
    /// Validates if both latitude and longitude are within their allowed ranges.
    /// </summary>
    /// <param name="latitude">The latitude to validate.</param>
    /// <param name="longitude">The longitude to validate.</param>
    /// <returns>True if both coordinates are valid, otherwise false.</returns>
    public static bool ValidateCoordinates(double latitude, double longitude)
    {
        return ValidateLatitude(latitude) && ValidateLongitude(longitude);
    }

    /// <summary>
    /// Validates if the coordinates within a PointDto are valid.
    /// </summary>
    /// <param name="point">The PointDto to validate.</param>
    /// <returns>True if the point coordinates are valid, otherwise false.</returns>
    public static bool ValidatePoint(PointDto? point)
    {
        if (point == null)
            return false;

        return ValidateCoordinates(point.Latitude, point.Longitude);
    }

    // Add other location-related validations here if needed, e.g., elevation.
}
