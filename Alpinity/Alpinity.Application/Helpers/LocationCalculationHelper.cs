namespace Alpinity.Application.Helpers;

using System.Collections.Generic;
using System.Linq;
using NetTopologySuite.Geometries;
using Alpinity.Domain.Entities;

/// <summary>
/// Helper class for calculating geographic data related to crags and sectors.
/// </summary>
public static class LocationCalculationHelper
{
    /// <summary>
    /// Computes the average location (centroid) from a collection of sectors.
    /// Returns null if no sector has a location.
    /// </summary>
    public static Point? CalculateAverageLocation(IEnumerable<Sector>? sectors)
    {
        if (sectors == null)
            return null;

        var sectorsWithLocations = sectors.Where(s => s.Location != null).ToList();
        if (!sectorsWithLocations.Any())
            return null;

        // Average latitude (Y) and longitude (X)
        var avgLatitude = sectorsWithLocations.Average(s => s.Location!.Y);
        var avgLongitude = sectorsWithLocations.Average(s => s.Location!.X);

        // Create a new Point with SRID 4326
        return new Point(avgLongitude, avgLatitude) { SRID = 4326 };
    }
}