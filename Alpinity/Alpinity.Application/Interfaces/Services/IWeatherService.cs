using Alpinity.Domain.ServiceResponses;

namespace Alpinity.Application.Interfaces.Services;

public interface IWeatherService
{
    Task<WeatherInformationResponse> GetWeatherInformationAsync(double lat, double lon);
}
