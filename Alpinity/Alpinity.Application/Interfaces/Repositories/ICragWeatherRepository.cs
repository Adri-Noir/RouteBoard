using Alpinity.Domain.Entities;
using Alpinity.Domain.ServiceResponses;

namespace Alpinity.Application.Interfaces.Repositories;

public interface ICragWeatherRepository
{
    Task<CragWeather?> GetLatestWeatherForCragAsync(Guid cragId);
    Task<CragWeather> SaveWeatherForCragAsync(Guid cragId, WeatherInformationResponse weatherData);
} 