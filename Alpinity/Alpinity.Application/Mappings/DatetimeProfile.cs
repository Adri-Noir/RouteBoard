using AutoMapper;

namespace Alpinity.Application.Mappings;

public class DatetimeProfile : Profile
{
    public DatetimeProfile()
    {
        CreateMap<DateTime, string>().ConvertUsing(s => s.ToString("yyyy-MM-ddTHH:mm:ss"));
    }
}