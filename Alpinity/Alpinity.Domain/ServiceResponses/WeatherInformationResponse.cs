namespace Alpinity.Domain.ServiceResponses;

public class WeatherInformationResponse
{
    public Current Current { get; set; }
    public ICollection<Hourly> Hourly { get; set; } = [];
    public ICollection<Daily> Daily { get; set; } = [];
}

public class Current
{
    public DateTime Time { get; set; }
    public int Interval { get; set; }
    public double Temperature2m { get; set; }
    public int RelativeHumidity2m { get; set; }
    public double WindSpeed10m { get; set; }
    public int WindDirection10m { get; set; }
    public int WeatherCode { get; set; }
}

public class Hourly
{
    public DateTime Time { get; set; }
    public double Temperature2m { get; set; }
    public int RelativeHumidity2m { get; set; }
    public double Rain { get; set; }
    public int PrecipitationProbability { get; set; }
    public int WeatherCode { get; set; }
    public double WindSpeed10m { get; set; }
    public int WindDirection10m { get; set; }
}

public class Daily
{
    public DateOnly Date { get; set; }
    public int WeatherCode { get; set; }
    public double Temperature2mMax { get; set; }
    public double Temperature2mMin { get; set; }
    public double ApparentTemperatureMax { get; set; }
    public double ApparentTemperatureMin { get; set; }
    public DateTime Sunrise { get; set; }
    public DateTime Sunset { get; set; }
    public double UvIndexMax { get; set; }
    public double PrecipitationSum { get; set; }
    public int PrecipitationProbabilityMax { get; set; }
    public double WindSpeed10mMax { get; set; }
    public int WindDirection10mDominant { get; set; }
}
