using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Domain.ServiceResponses;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class CragWeatherRepository(ApplicationDbContext dbContext) : ICragWeatherRepository
{
    public async Task<CragWeather?> GetLatestWeatherForCragAsync(Guid cragId)
    {
        return await dbContext.CragWeathers
            .Where(cw => cw.CragId == cragId)
            .OrderByDescending(cw => cw.Timestamp)
            .FirstOrDefaultAsync();
    }

    public async Task<CragWeather> SaveWeatherForCragAsync(Guid cragId, WeatherInformationResponse weatherData)
    {
        var cragWeather = CragWeather.Create(cragId, weatherData);
        
        dbContext.CragWeathers.Add(cragWeather);
        await dbContext.SaveChangesAsync();
        
        return cragWeather;
    }
} 