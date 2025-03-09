using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace Alpinity.Domain.ServiceResponses;

public class WeatherInformationResponse
{
    [JsonPropertyName("lat")]
    public double Latitude { get; set; }

    [JsonPropertyName("lon")]
    public double Longitude { get; set; }

    [JsonPropertyName("timezone")]
    public string Timezone { get; set; }

    [JsonPropertyName("timezone_offset")]
    public int TimezoneOffset { get; set; }

    [JsonPropertyName("current")]
    public CurrentWeather Current { get; set; }

    [JsonPropertyName("minutely")]
    public List<MinutelyForecast> Minutely { get; set; }

    [JsonPropertyName("hourly")]
    public List<HourlyForecast> Hourly { get; set; }

    [JsonPropertyName("daily")]
    public List<DailyForecast> Daily { get; set; }

    [JsonPropertyName("alerts")]
    public List<WeatherAlert> Alerts { get; set; }
}

public class CurrentWeather
{
    [JsonPropertyName("dt")]
    public long DateTime { get; set; }

    [JsonPropertyName("sunrise")]
    public long Sunrise { get; set; }

    [JsonPropertyName("sunset")]
    public long Sunset { get; set; }

    [JsonPropertyName("temp")]
    public double Temperature { get; set; }

    [JsonPropertyName("feels_like")]
    public double FeelsLike { get; set; }

    [JsonPropertyName("pressure")]
    public int Pressure { get; set; }

    [JsonPropertyName("humidity")]
    public int Humidity { get; set; }

    [JsonPropertyName("dew_point")]
    public double DewPoint { get; set; }

    [JsonPropertyName("uvi")]
    public double UVIndex { get; set; }

    [JsonPropertyName("clouds")]
    public int Clouds { get; set; }

    [JsonPropertyName("visibility")]
    public int Visibility { get; set; }

    [JsonPropertyName("wind_speed")]
    public double WindSpeed { get; set; }

    [JsonPropertyName("wind_deg")]
    public int WindDegree { get; set; }

    [JsonPropertyName("wind_gust")]
    public double WindGust { get; set; }

    [JsonPropertyName("weather")]
    public List<Weather> Weather { get; set; }
}

public class Weather
{
    [JsonPropertyName("id")]
    public int Id { get; set; }

    [JsonPropertyName("main")]
    public string Main { get; set; }

    [JsonPropertyName("description")]
    public string Description { get; set; }

    [JsonPropertyName("icon")]
    public string Icon { get; set; }
}

public class MinutelyForecast
{
    [JsonPropertyName("dt")]
    public long DateTime { get; set; }

    [JsonPropertyName("precipitation")]
    public double Precipitation { get; set; }
}

public class HourlyForecast
{
    [JsonPropertyName("dt")]
    public long DateTime { get; set; }

    [JsonPropertyName("temp")]
    public double Temperature { get; set; }

    [JsonPropertyName("feels_like")]
    public double FeelsLike { get; set; }

    [JsonPropertyName("pressure")]
    public int Pressure { get; set; }

    [JsonPropertyName("humidity")]
    public int Humidity { get; set; }

    [JsonPropertyName("dew_point")]
    public double DewPoint { get; set; }

    [JsonPropertyName("uvi")]
    public double UVIndex { get; set; }

    [JsonPropertyName("clouds")]
    public int Clouds { get; set; }

    [JsonPropertyName("visibility")]
    public int Visibility { get; set; }

    [JsonPropertyName("wind_speed")]
    public double WindSpeed { get; set; }

    [JsonPropertyName("wind_deg")]
    public int WindDegree { get; set; }

    [JsonPropertyName("wind_gust")]
    public double WindGust { get; set; }

    [JsonPropertyName("weather")]
    public List<Weather> Weather { get; set; }

    [JsonPropertyName("pop")]
    public double ProbabilityOfPrecipitation { get; set; }
}

public class DailyForecast
{
    [JsonPropertyName("dt")]
    public long DateTime { get; set; }

    [JsonPropertyName("sunrise")]
    public long Sunrise { get; set; }

    [JsonPropertyName("sunset")]
    public long Sunset { get; set; }

    [JsonPropertyName("moonrise")]
    public long Moonrise { get; set; }

    [JsonPropertyName("moonset")]
    public long Moonset { get; set; }

    [JsonPropertyName("moon_phase")]
    public double MoonPhase { get; set; }

    [JsonPropertyName("summary")]
    public string Summary { get; set; }

    [JsonPropertyName("temp")]
    public Temperature Temperature { get; set; }

    [JsonPropertyName("feels_like")]
    public FeelsLike FeelsLike { get; set; }

    [JsonPropertyName("pressure")]
    public int Pressure { get; set; }

    [JsonPropertyName("humidity")]
    public int Humidity { get; set; }

    [JsonPropertyName("dew_point")]
    public double DewPoint { get; set; }

    [JsonPropertyName("wind_speed")]
    public double WindSpeed { get; set; }

    [JsonPropertyName("wind_deg")]
    public int WindDegree { get; set; }

    [JsonPropertyName("wind_gust")]
    public double WindGust { get; set; }

    [JsonPropertyName("weather")]
    public List<Weather> Weather { get; set; }

    [JsonPropertyName("clouds")]
    public int Clouds { get; set; }

    [JsonPropertyName("pop")]
    public double ProbabilityOfPrecipitation { get; set; }

    [JsonPropertyName("rain")]
    public double Rain { get; set; }

    [JsonPropertyName("uvi")]
    public double UVIndex { get; set; }
}

public class Temperature
{
    [JsonPropertyName("day")]
    public double Day { get; set; }

    [JsonPropertyName("min")]
    public double Min { get; set; }

    [JsonPropertyName("max")]
    public double Max { get; set; }

    [JsonPropertyName("night")]
    public double Night { get; set; }

    [JsonPropertyName("eve")]
    public double Evening { get; set; }

    [JsonPropertyName("morn")]
    public double Morning { get; set; }
}

public class FeelsLike
{
    [JsonPropertyName("day")]
    public double Day { get; set; }

    [JsonPropertyName("night")]
    public double Night { get; set; }

    [JsonPropertyName("eve")]
    public double Evening { get; set; }

    [JsonPropertyName("morn")]
    public double Morning { get; set; }
}

public class WeatherAlert
{
    [JsonPropertyName("sender_name")]
    public string SenderName { get; set; }

    [JsonPropertyName("event")]
    public string Event { get; set; }

    [JsonPropertyName("start")]
    public long Start { get; set; }

    [JsonPropertyName("end")]
    public long End { get; set; }

    [JsonPropertyName("description")]
    public string Description { get; set; }

    [JsonPropertyName("tags")]
    public List<string> Tags { get; set; }
}