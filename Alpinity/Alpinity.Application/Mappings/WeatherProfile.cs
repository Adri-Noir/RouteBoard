using Alpinity.Application.UseCases.Map.Dtos;
using Alpinity.Domain.ServiceResponses;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class WeatherProfile : Profile
{
    public WeatherProfile()
    {
        CreateMap<WeatherInformationResponse, WeatherResponseDto>();
        CreateMap<Current, CurrentWeatherDto>();
        CreateMap<Hourly, HourlyWeatherDto>();
        CreateMap<Daily, DailyWeatherDto>();
    }
}
