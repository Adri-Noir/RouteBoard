using System.Text.Json;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Domain.ServiceResponses;
using Microsoft.Extensions.Configuration;

namespace Alpinity.Infrastructure.Services;

public class WeatherService(IConfiguration configuration): IWeatherService
{
    public async Task<WeatherInformationResponse> GetWeatherInformationAsync(double lat, double lon)
    {
        var client = new HttpClient();
        var response = await client.GetAsync($"https://api.openweathermap.org/data/3.0/onecall?lat={lat}&lon={lon}&exclude=minutely,alerts&appid={configuration["OpenWeather:ApiKey"]}");
        
        response.EnsureSuccessStatusCode();
        
        var content = await response.Content.ReadAsStringAsync();
        var weatherInformation = JsonSerializer.Deserialize<WeatherInformationResponse>(content) ?? throw new Exception("Weather information not found");
        return weatherInformation;
    }
}
