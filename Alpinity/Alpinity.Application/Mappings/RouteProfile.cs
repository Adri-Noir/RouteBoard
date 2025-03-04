using Alpinity.Application.UseCases.Routes.Commands.Create;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Application.UseCases.Sectors.Dtos;
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
            .ForMember(t => t.SectorName, opt => opt.MapFrom(s => s.Sector!.Name))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Sector!.Crag!.Name));

        CreateMap<Route, SectorRouteDto>()
            .ForMember(t => t.AscentsCount, opt => opt.MapFrom(s => s.Ascents!.Count));

        CreateMap<Route, RecentlyAscendedRouteDto>()
            .ForMember(t => t.SectorId, opt => opt.MapFrom(s => s.Sector!.Id))
            .ForMember(t => t.SectorName, opt => opt.MapFrom(s => s.Sector!.Name))
            .ForMember(t => t.CragId, opt => opt.MapFrom(s => s.Sector!.Crag!.Id))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Sector!.Crag!.Name))
            .ForMember(t => t.AscentsCount, opt => opt.MapFrom(s => s.Ascents!.Count));

        CreateMap<CreateRouteCommand, Route>();
    }
}