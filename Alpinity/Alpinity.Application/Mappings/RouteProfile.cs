using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class RouteProfile : Profile
{
    public RouteProfile()
    {
        CreateMap<Route, RouteSimpleDto>()
            .ForMember(t => t.PhotoUrl, opt => opt.MapFrom(s => s.RoutePhotos.FirstOrDefault().Image.Url));

        CreateMap<Route, RouteDetailedDto>()
            .ForMember(t => t.SectorName, opt => opt.MapFrom(s => s.Sector.Name))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Sector.Crag.Name))
            .ForMember(
                dest => dest.RouteType,
                opt => opt.MapFrom(src => Enum.GetValues(typeof(RouteType))
                    .Cast<RouteType>()
                    .Where(value => src.RouteType.HasFlag(value) && value != 0)
                    .Select(value => value.ToString())
                    .ToList()));
    }
}