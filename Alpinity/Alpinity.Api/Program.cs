using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;
using Alpinity.Api.Extensions;
using Alpinity.Api.ProblemDetails;
using Alpinity.Api.Services;
using Alpinity.Application;
using Alpinity.Application.Interfaces;
using Alpinity.Infrastructure;
using Alpinity.Infrastructure.Persistence;
using Alpinity.Infrastructure.Persistence.Seed;
using Hellang.Middleware.ProblemDetails;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader();
    });
});


var services = builder.Services;
ConfigureServices(services, builder.Configuration, builder.Environment);

var app = builder.Build();

await FillDatabase(app.Services, builder.Configuration);

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseProblemDetails();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.UseCors("AllowAll");

app.Run();

public partial class Program
{
    public static void ConfigureServices(
        IServiceCollection services,
        IConfiguration configuration,
        IWebHostEnvironment environment)
    {
        services
            .AddControllers()
            .AddJsonOptions(options =>
            {
                options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
                options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
                options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
                options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
                options.JsonSerializerOptions.NumberHandling = JsonNumberHandling.AllowReadingFromString;
                options.JsonSerializerOptions.WriteIndented = false;
            });
        services.AddEndpointsApiExplorer();
        services.AddLogging();

        services.AddSwagger();

        services.AddApplication(configuration);
        services.AddInfrastructure(configuration);

        services.AddHttpContextAccessor();

        services.AddJwtAuthorization(configuration);

        services.AddAutoMapper(Assembly.GetExecutingAssembly());

        services.AddCustomProblemDetailsResponses(environment);

        services.AddScoped<IAuthenticationContext, AuthenticationContext>();
    }

    public static async Task FillDatabase(IServiceProvider serviceProvider, IConfiguration configuration)
    {
        using var scope = serviceProvider.CreateScope();
        var services = scope.ServiceProvider;

        var context = services.GetRequiredService<ApplicationDbContext>();
        if (configuration.GetConnectionString("DefaultConnection") == "TestConnectionString")
            await context.Database.EnsureCreatedAsync();
        else
            await context.Database.MigrateAsync();

        await UserSeed.Seed(context);
        await CragSectorRouteSeed.Seed(context);
    }
}