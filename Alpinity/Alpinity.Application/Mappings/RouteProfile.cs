using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class RouteProfile: Profile
{
    public RouteProfile()
    {
        CreateMap<Route, RouteSimpleDto>()
            .ForMember(t => t.PhotoUrl, opt => opt.MapFrom(s => s.RoutePhotos.FirstOrDefault().Image.Url));
        
        CreateMap<Route, RouteDetailedDto>()
            .ForMember(t => t.SectorName, opt => opt.MapFrom(s => s.Sector.Name))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Sector.Crag.Name));
    }
}