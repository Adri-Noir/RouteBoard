using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using Alpinity.Domain.ServiceResponses;
using Alpinity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Alpinity.Infrastructure.Repositories;

public class CragWeatherRepository(ApplicationDbContext dbContext) : ICragWeatherRepository
{
    public async Task<CragWeather?> GetLatestWeatherForCragAsync(Guid cragId, CancellationToken cancellationToken = default)
    {
        return await dbContext.CragWeathers
            .Where(cw => cw.CragId == cragId)
            .OrderByDescending(cw => cw.Timestamp)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<CragWeather> SaveWeatherForCragAsync(Guid cragId, WeatherInformationResponse weatherData, CancellationToken cancellationToken = default)
    {
        // Delete previous weather records for this crag
        var previousWeathers = await dbContext.CragWeathers
            .Where(cw => cw.CragId == cragId)
            .ToListAsync(cancellationToken);

        if (previousWeathers.Any())
        {
            dbContext.CragWeathers.RemoveRange(previousWeathers);
        }

        var cragWeather = CragWeather.Create(cragId, weatherData);

        dbContext.CragWeathers.Add(cragWeather);
        await dbContext.SaveChangesAsync(cancellationToken);

        return cragWeather;
    }
}