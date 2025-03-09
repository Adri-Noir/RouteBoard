using System.Text.Json;
using Alpinity.Domain.ServiceResponses;

namespace Alpinity.Domain.Entities;

public class CragWeather
{
    public int Id { get; set; }
    public Guid CragId { get; set; }
    public DateTime Timestamp { get; set; }
    public string WeatherData { get; set; } = null!;
    
    // Navigation properties
    public Crag Crag { get; set; } = null!;
    
    // Helper methods
    public WeatherInformationResponse GetWeatherInformation()
    {
        return JsonSerializer.Deserialize<WeatherInformationResponse>(WeatherData)!;
    }
    
    public static CragWeather Create(Guid cragId, WeatherInformationResponse weatherData)
    {
        return new CragWeather
        {
            CragId = cragId,
            Timestamp = DateTime.UtcNow,
            WeatherData = JsonSerializer.Serialize(weatherData)
        };
    }
    
    public bool IsExpired()
    {
        return DateTime.UtcNow.Subtract(Timestamp).TotalHours > 4;
    }
} 