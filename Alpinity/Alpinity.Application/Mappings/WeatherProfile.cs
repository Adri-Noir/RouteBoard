using Alpinity.Application.UseCases.Map.Dtos;
using Alpinity.Domain.ServiceResponses;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class WeatherProfile : Profile
{
    public WeatherProfile()
    {
        CreateMap<WeatherInformationResponse, WeatherResponseDto>()
            .ForMember(dest => dest.CurrentWeather, opt => opt.MapFrom(src => src.Current))
            .ForMember(dest => dest.Hourly, opt => opt.MapFrom(src => src.Hourly))
            .ForMember(dest => dest.Daily, opt => opt.MapFrom(src => src.Daily.Skip(1).ToList()));

        CreateMap<CurrentWeather, CurrentWeatherDto>()
            .ForMember(dest => dest.DateTime, opt => opt.MapFrom(src => ConvertUnixTimestampToDateTime(src.DateTime)))
            .ForMember(dest => dest.Sunrise, opt => opt.MapFrom(src => ConvertUnixTimestampToDateTime(src.Sunrise)))
            .ForMember(dest => dest.Sunset, opt => opt.MapFrom(src => ConvertUnixTimestampToDateTime(src.Sunset)))
            .ForMember(dest => dest.Weather, opt => opt.MapFrom(src => src.Weather.FirstOrDefault()));

        CreateMap<HourlyForecast, HourlyForecastDto>()
            .ForMember(dest => dest.DateTime, opt => opt.MapFrom(src => ConvertUnixTimestampToDateTime(src.DateTime)))
            .ForMember(dest => dest.Weather, opt => opt.MapFrom(src => src.Weather.FirstOrDefault()));

        CreateMap<DailyForecast, DailyForecastDto>()
            .ForMember(dest => dest.Date, opt => opt.MapFrom(src => ConvertUnixTimestampToDateOnly(src.DateTime)))
            .ForMember(dest => dest.Weather, opt => opt.MapFrom(src => src.Weather.FirstOrDefault()));

        CreateMap<Weather, WeatherDto>();
        CreateMap<Temperature, TemperatureDto>();
        CreateMap<FeelsLike, FeelsLikeDto>();
    }

    private string ConvertUnixTimestampToDateTime(long unixTimeStamp)
    {
        DateTime dateTime = DateTimeOffset.FromUnixTimeSeconds(unixTimeStamp).DateTime;
        return dateTime.ToString("o");
    }

    private string ConvertUnixTimestampToDateOnly(long unixTimeStamp)
    {
        DateTime dateTime = DateTimeOffset.FromUnixTimeSeconds(unixTimeStamp).DateTime;
        return dateTime.ToString("yyyy-MM-dd");
    }
}
