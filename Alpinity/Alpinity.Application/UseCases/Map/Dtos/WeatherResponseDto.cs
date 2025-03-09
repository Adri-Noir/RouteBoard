namespace Alpinity.Application.UseCases.Map.Dtos;

public class WeatherResponseDto
{
    public CurrentWeatherDto CurrentWeather { get; set; }
    public List<HourlyForecastDto> Hourly { get; set; }
    public List<DailyForecastDto> Daily { get; set; }
}

public class CurrentWeatherDto
{
    public string DateTime { get; set; }

    public string Sunrise { get; set; }

    public string Sunset { get; set; }

    public double Temperature { get; set; }

    public double FeelsLike { get; set; }

    public int Pressure { get; set; }

    public int Humidity { get; set; }

    public double DewPoint { get; set; }

    public double UVIndex { get; set; }

    public int Clouds { get; set; }

    public int Visibility { get; set; }

    public double WindSpeed { get; set; }

    public int WindDegree { get; set; }

    public double WindGust { get; set; }

    public WeatherDto Weather { get; set; }
}

public class WeatherDto
{
    public int Id { get; set; }

    public string Main { get; set; }

    public string Description { get; set; }

    public string Icon { get; set; }
}

public class HourlyForecastDto
{
    public string DateTime { get; set; }

    public double Temperature { get; set; }

    public double FeelsLike { get; set; }

    public int Pressure { get; set; }

    public int Humidity { get; set; }

    public double DewPoint { get; set; }

    public double UVIndex { get; set; }

    public int Clouds { get; set; }

    public int Visibility { get; set; }

    public double WindSpeed { get; set; }

    public int WindDegree { get; set; }

    public double WindGust { get; set; }

    public WeatherDto Weather { get; set; }

    public double ProbabilityOfPrecipitation { get; set; }
}

public class DailyForecastDto
{
    public string Date { get; set; }

    public TemperatureDto Temperature { get; set; }

    public FeelsLikeDto FeelsLike { get; set; }

    public int Pressure { get; set; }

    public int Humidity { get; set; }

    public double DewPoint { get; set; }

    public double WindSpeed { get; set; }

    public int WindDegree { get; set; }

    public double WindGust { get; set; }

    public WeatherDto Weather { get; set; }

    public int Clouds { get; set; }

    public double ProbabilityOfPrecipitation { get; set; }

    public double Rain { get; set; }

    public double UVIndex { get; set; }
}

public class TemperatureDto
{
    public double Day { get; set; }

    public double Min { get; set; }

    public double Max { get; set; }

    public double Night { get; set; }

    public double Evening { get; set; }

    public double Morning { get; set; }
}

public class FeelsLikeDto
{
    public double Day { get; set; }

    public double Night { get; set; }

    public double Evening { get; set; }

    public double Morning { get; set; }
}