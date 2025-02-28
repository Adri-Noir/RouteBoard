using AutoMapper;

namespace Alpinity.Application.Mappings;

public class DateOnlyProfile : Profile
{
    public DateOnlyProfile()
    {
        CreateMap<DateOnly, string>().ConvertUsing(d => d.ToString());
    }
}
