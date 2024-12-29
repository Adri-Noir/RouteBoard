using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Infrastructure.Persistence;
using Alpinity.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

namespace Alpinity.Infrastructure;

public static class ServiceExtensions
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"), sqlOption =>
                sqlOption.UseNetTopologySuite())
        );
        
        
        services.AddTransient<IFileRepository>(_ =>
            new AzureFileRepository(configuration.GetConnectionString("BlobConnection")!)
        );
        services.AddTransient<ICragRepository, CragRepository>();
        services.AddTransient<ISectorRepository, SectorRepository>();
        services.AddTransient<IRouteRepository, RouteRepository>();
        services.AddTransient<IPhotoRepository, PhotoRepository>();

        return services;
    }
}