using System;
using Alpinity.Domain.ServiceResponses;

namespace Alpinity.Application.UseCases.Map.Dtos;

public class WeatherResponseDto
{
    public CurrentWeatherDto Current { get; set; }
    public ICollection<HourlyWeatherDto> Hourly { get; set; } = [];
    public ICollection<DailyWeatherDto> Daily { get; set; } = [];
}

public class CurrentWeatherDto
{
    public string Time { get; set; }
    public int Interval { get; set; }
    public double Temperature2m { get; set; }
    public int RelativeHumidity2m { get; set; }
    public double WindSpeed10m { get; set; }
    public int WindDirection10m { get; set; }
    public int WeatherCode { get; set; }
}

public class HourlyWeatherDto
{
    public string Time { get; set; }
    public double Temperature2m { get; set; }
    public int RelativeHumidity2m { get; set; }
    public double Rain { get; set; }
    public int WeatherCode { get; set; }
    public double WindSpeed10m { get; set; }
    public int WindDirection10m { get; set; }
    public int PrecipitationProbability { get; set; }
}

public class DailyWeatherDto
{
    public string Date { get; set; }
    public int WeatherCode { get; set; }
    public double Temperature2mMax { get; set; }
    public double Temperature2mMin { get; set; }
    public double ApparentTemperatureMax { get; set; }
    public double ApparentTemperatureMin { get; set; }
    public string Sunrise { get; set; }
    public string Sunset { get; set; }
    public double UvIndexMax { get; set; }
    public double PrecipitationSum { get; set; }
    public int PrecipitationProbabilityMax { get; set; }
    public double WindSpeed10mMax { get; set; }
    public int WindDirection10mDominant { get; set; }
}