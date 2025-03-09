using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Application.Services;
using Alpinity.Infrastructure.Identity;
using Alpinity.Infrastructure.Persistence;
using Alpinity.Infrastructure.Repositories;
using Alpinity.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Alpinity.Infrastructure;

public static class ServiceExtensions
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>(options =>
        {
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"), sqlOption =>
                sqlOption.UseNetTopologySuite());
            options.EnableSensitiveDataLogging();
        });

        services.AddTransient<ISignInService, SignInService>();

        services.AddTransient<IFileRepository>(_ =>
            new AzureFileRepository(configuration.GetConnectionString("BlobConnection")!)
        );
        services.AddTransient<ICragRepository, CragRepository>();
        services.AddTransient<ISectorRepository, SectorRepository>();
        services.AddTransient<IRouteRepository, RouteRepository>();
        services.AddTransient<IPhotoRepository, PhotoRepository>();
        services.AddTransient<IUserRepository, UserRepository>();
        services.AddTransient<IAscentRepository, AscentRepository>();
        services.AddTransient<ISearchHistoryRepository, SearchHistoryRepository>();
        services.AddTransient<ICragWeatherRepository, CragWeatherRepository>();
        services.AddTransient<ILocationInformationService, LocationInformationService>();
        services.AddTransient<IWeatherService, WeatherService>();
        
        return services;
    }
}