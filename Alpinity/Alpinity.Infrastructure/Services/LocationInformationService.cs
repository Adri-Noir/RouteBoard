using System.Text.Json;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Domain.ServiceResponses;
using Microsoft.Extensions.Configuration;

namespace Alpinity.Infrastructure.Services;

public class LocationInformationService(IConfiguration configuration) : ILocationInformationService
{
    public async Task<LocationInformationResponse> GetLocationInformationFromCoordinates(double latitude, double longitude)
    {
        var client = new HttpClient();  
        var response = await client.GetAsync($"https://api.mapbox.com/search/geocode/v6/reverse?longitude={longitude}&latitude={latitude}&access_token={configuration["Mapbox:AccessToken"]}");

        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        var locationInformation = JsonSerializer.Deserialize<LocationInformationResponse>(content);
        if (locationInformation == null)
        {
            throw new Exception("Location information not found");
        }
        return locationInformation;
    }

    public string? GetLocationNameFromLocationInformation(LocationInformationResponse? locationInformation)
    {
        if (locationInformation == null || locationInformation.Features == null || locationInformation.Features.Count == 0)
        {
            return null;
        }

        foreach (var feature in locationInformation.Features)
        {
            if (feature.Properties != null && feature.Properties.FeatureType == FeatureType.Region)
            {
                return feature.Properties.FullAddress;
            }
        }

        return locationInformation.Features[^1].Properties?.FullAddress;
    }
}
