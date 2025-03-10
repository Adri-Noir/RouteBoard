using System.Text.Json;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Domain.ServiceResponses;
using Microsoft.Extensions.Configuration;

namespace Alpinity.Infrastructure.Services;

public class WeatherService : IWeatherService
{
    public async Task<WeatherInformationResponse> GetWeatherInformationAsync(double lat, double lon)
    {
        var client = new HttpClient();
        var response = await client.GetAsync(
            $"https://api.open-meteo.com/v1/forecast?latitude={lat.ToString("0.00000000", System.Globalization.CultureInfo.InvariantCulture)}&longitude={lon.ToString("0.00000000", System.Globalization.CultureInfo.InvariantCulture)}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,weather_code&hourly=temperature_2m,relative_humidity_2m,rain,precipitation_probability,weather_code,wind_speed_10m,wind_direction_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_direction_10m_dominant&forecast_days=14");

        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        var jsonData = JsonDocument.Parse(content).RootElement;

        var weatherInformation = new WeatherInformationResponse
        {
            Current = MapCurrent(jsonData),
            Hourly = MapHourly(jsonData),
            Daily = MapDaily(jsonData)
        };

        return weatherInformation;
    }

    private Current MapCurrent(JsonElement jsonData)
    {
        var currentData = jsonData.GetProperty("current");

        return new Current
        {
            Time = DateTime.Parse(currentData.GetProperty("time").GetString() ?? string.Empty),
            Interval = currentData.GetProperty("interval").GetInt32(),
            Temperature2m = currentData.GetProperty("temperature_2m").GetDouble(),
            RelativeHumidity2m = currentData.GetProperty("relative_humidity_2m").GetInt32(),
            WindSpeed10m = currentData.GetProperty("wind_speed_10m").GetDouble(),
            WindDirection10m = currentData.GetProperty("wind_direction_10m").GetInt32(),
            WeatherCode = currentData.GetProperty("weather_code").GetInt32()
        };
    }

    private ICollection<Hourly> MapHourly(JsonElement jsonData)
    {
        var hourlyData = jsonData.GetProperty("hourly");
        var times = hourlyData.GetProperty("time").EnumerateArray().Select(x => x.GetString()).ToArray();
        var temperatures = hourlyData.GetProperty("temperature_2m").EnumerateArray().Select(x => x.GetDouble())
            .ToArray();
        var humidities = hourlyData.GetProperty("relative_humidity_2m").EnumerateArray().Select(x => x.GetInt32())
            .ToArray();
        var rains = hourlyData.GetProperty("rain").EnumerateArray().Select(x => x.GetDouble()).ToArray();
        var weatherCodes = hourlyData.GetProperty("weather_code").EnumerateArray().Select(x => x.GetInt32()).ToArray();
        var windSpeeds = hourlyData.GetProperty("wind_speed_10m").EnumerateArray().Select(x => x.GetDouble()).ToArray();
        var windDirections = hourlyData.GetProperty("wind_direction_10m").EnumerateArray().Select(x => x.GetInt32())
            .ToArray();
        var precipitationProbabilities = hourlyData.GetProperty("precipitation_probability").EnumerateArray().Select(x => x.GetInt32()).ToArray();

        var hourlyItems = new List<Hourly>();

        for (var i = 0; i < times.Length; i++)
            hourlyItems.Add(new Hourly
            {
                Time = DateTime.Parse(times[i] ?? string.Empty),
                Temperature2m = temperatures[i],
                RelativeHumidity2m = humidities[i],
                Rain = rains[i],
                WeatherCode = weatherCodes[i],
                WindSpeed10m = windSpeeds[i],
                WindDirection10m = windDirections[i],
                PrecipitationProbability = precipitationProbabilities[i]
            });

        return hourlyItems;
    }

    private ICollection<Daily> MapDaily(JsonElement jsonData)
    {
        var dailyData = jsonData.GetProperty("daily");
        var dates = dailyData.GetProperty("time").EnumerateArray().Select(x => x.GetString()).ToArray();
        var weatherCodes = dailyData.GetProperty("weather_code").EnumerateArray().Select(x => x.GetInt32()).ToArray();
        var maxTemps = dailyData.GetProperty("temperature_2m_max").EnumerateArray().Select(x => x.GetDouble())
            .ToArray();
        var minTemps = dailyData.GetProperty("temperature_2m_min").EnumerateArray().Select(x => x.GetDouble())
            .ToArray();
        var apparentMaxTemps = dailyData.GetProperty("apparent_temperature_max").EnumerateArray()
            .Select(x => x.GetDouble()).ToArray();
        var apparentMinTemps = dailyData.GetProperty("apparent_temperature_min").EnumerateArray()
            .Select(x => x.GetDouble()).ToArray();
        var sunrises = dailyData.GetProperty("sunrise").EnumerateArray().Select(x => x.GetString()).ToArray();
        var sunsets = dailyData.GetProperty("sunset").EnumerateArray().Select(x => x.GetString()).ToArray();
        var uvIndices = dailyData.GetProperty("uv_index_max").EnumerateArray().Select(x => x.GetDouble()).ToArray();
        var precipSums = dailyData.GetProperty("precipitation_sum").EnumerateArray().Select(x => x.GetDouble())
            .ToArray();
        var precipProbabilities = dailyData.GetProperty("precipitation_probability_max").EnumerateArray()
            .Select(x => x.GetInt32()).ToArray();
        var windSpeeds = dailyData.GetProperty("wind_speed_10m_max").EnumerateArray().Select(x => x.GetDouble())
            .ToArray();
        var windDirections = dailyData.GetProperty("wind_direction_10m_dominant").EnumerateArray()
            .Select(x => x.GetInt32()).ToArray();

        var dailyItems = new List<Daily>();

        for (var i = 0; i < dates.Length; i++)
            dailyItems.Add(new Daily
            {
                Date = DateOnly.Parse(dates[i] ?? string.Empty),
                WeatherCode = weatherCodes[i],
                Temperature2mMax = maxTemps[i],
                Temperature2mMin = minTemps[i],
                ApparentTemperatureMax = apparentMaxTemps[i],
                ApparentTemperatureMin = apparentMinTemps[i],
                Sunrise = DateTime.Parse(sunrises[i] ?? string.Empty),
                Sunset = DateTime.Parse(sunsets[i] ?? string.Empty),
                UvIndexMax = uvIndices[i],
                PrecipitationSum = precipSums[i],
                PrecipitationProbabilityMax = precipProbabilities[i],
                WindSpeed10mMax = windSpeeds[i],
                WindDirection10mDominant = windDirections[i]
            });

        return dailyItems;
    }
}