namespace Alpinity.Application.Configuration;

public class JwtConfiguration
{
    public const string ConfigKey = "Jwt";

    public required string Key { get; set; }
    public required string Issuer { get; set; }
    public required string Audience { get; set; }
    public required double DurationInMinutes { get; set; }
}