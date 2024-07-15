using System.Reflection;
using Alpinity.Application.Behaviours.Validation;
using Alpinity.Application.Configuration;
using MediatR;
using FluentValidation;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Alpinity.Application;

public static class ServiceExtensions
{
    public static IServiceCollection AddApplication(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var assembly = Assembly.GetExecutingAssembly();

        services.AddAutoMapper(assembly);
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(assembly));
        services.AddValidatorsFromAssemblies( new[] { assembly });
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));
        services.Configure<JwtConfiguration>(configuration.GetSection(JwtConfiguration.ConfigKey));
        return services;
    }
}