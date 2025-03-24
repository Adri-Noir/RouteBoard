using Alpinity.Application.Interfaces.Repositories;
using AutoMapper;
using Microsoft.Extensions.DependencyInjection;

namespace Alpinity.Application.Mappings;

public static class AutoMapperExtensions
{
    public static IServiceCollection AddAutoMapperValueResolvers(this IServiceCollection services)
    {
        // Register custom value resolvers for AutoMapper
        services.AddTransient<TemporaryUrlResolver>();

        // Configure AutoMapper to use the IValueConverter instance from DI
        services.AddSingleton<IConfigurationProvider>(provider =>
        {
            var mapperConfig = new MapperConfiguration(cfg =>
            {
                // Register our value resolver factory
                cfg.ConstructServicesUsing(type => provider.GetRequiredService(type));

                // Register all profiles from the assembly
                cfg.AddMaps(typeof(PhotoProfile).Assembly);
            });

            return mapperConfig;
        });

        // Create the mapper with the configuration
        services.AddSingleton<IMapper>(provider =>
            provider.GetRequiredService<IConfigurationProvider>().CreateMapper());

        return services;
    }
}