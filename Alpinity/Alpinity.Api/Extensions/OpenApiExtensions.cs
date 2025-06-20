using System.Reflection;
using Microsoft.OpenApi.Models;

namespace Alpinity.Api.Extensions;

public static class OpenApiExtensions
{
    public static IServiceCollection AddSwagger(
        this IServiceCollection services)
    {
        services.AddSwaggerGen(setup =>
        {
            setup.EnableAnnotations();

            setup.AddServer(new OpenApiServer
            {
                Url = "https://192.168.50.253:7244",
                Description = "Local Dev server"
            });

            setup.AddServer(new OpenApiServer
            {
                Url = "https://localhost:7244",
                Description = "Dev server"
            });

            setup.AddSecurityDefinition(
                "Bearer",
                new OpenApiSecurityScheme
                {
                    Description = @"JWT Authorization token using the Bearer scheme. <br>
                      Enter 'Bearer' [space] and then your token in the text input below. <br>
                      Example: 'Bearer 12345abcdef'",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.ApiKey,
                    Scheme = "Bearer"
                });

            setup.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        },
                        Scheme = "oauth2",
                        Name = "Authorization",
                        In = ParameterLocation.Header
                    },
                    new List<string>()
                }
            });

            var currentAssembly = Assembly.GetExecutingAssembly();
            var xmlDocs = currentAssembly.GetReferencedAssemblies()
                .Union(new[] { currentAssembly.GetName() })
                .Select(a => Path.Combine(Path.GetDirectoryName(currentAssembly.Location)!, $"{a.Name}.xml"))
                .Where(File.Exists)
                .ToArray();
            Array.ForEach(xmlDocs, d => setup.IncludeXmlComments(d));
        });

        return services;
    }
}