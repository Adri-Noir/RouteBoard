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
        CreateMap<Route, RouteDetailedDto>()
            .ForMember(t => t.SectorName, opt => opt.MapFrom(s => s.Sector!.Name))
            .ForMember(t => t.CragId, opt => opt.MapFrom(s => s.Sector!.Crag!.Id))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Sector!.Crag!.Name))
            .ForMember(t => t.RouteCategories, opt => opt.MapFrom(s => new RouteCategoriesDto
            {
                ClimbTypes = s.Ascents != null ? s.Ascents.SelectMany(a => a.ClimbTypes ?? Enumerable.Empty<ClimbType>()).Distinct().ToList() : new List<ClimbType>(),
                RockTypes = s.Ascents != null ? s.Ascents.SelectMany(a => a.RockTypes ?? Enumerable.Empty<RockType>()).Distinct().ToList() : new List<RockType>(),
                HoldTypes = s.Ascents != null ? s.Ascents.SelectMany(a => a.HoldTypes ?? Enumerable.Empty<HoldType>()).Distinct().ToList() : new List<HoldType>()
            }));

        CreateMap<Route, SectorRouteDto>()
            .ForMember(t => t.AscentsCount, opt => opt.MapFrom(s => s.Ascents != null ? s.Ascents.Count : 0))
            .ForMember(t => t.RouteCategories, opt => opt.MapFrom(s => new RouteCategoriesDto
            {
                ClimbTypes = s.Ascents != null ? s.Ascents.SelectMany(a => a.ClimbTypes ?? Enumerable.Empty<ClimbType>()).Distinct().ToList() : new List<ClimbType>(),
                RockTypes = s.Ascents != null ? s.Ascents.SelectMany(a => a.RockTypes ?? Enumerable.Empty<RockType>()).Distinct().ToList() : new List<RockType>(),
                HoldTypes = s.Ascents != null ? s.Ascents.SelectMany(a => a.HoldTypes ?? Enumerable.Empty<HoldType>()).Distinct().ToList() : new List<HoldType>()
            }));

        CreateMap<Route, RecentlyAscendedRouteDto>()
            .ForMember(t => t.SectorId, opt => opt.MapFrom(s => s.Sector!.Id))
            .ForMember(t => t.SectorName, opt => opt.MapFrom(s => s.Sector!.Name))
            .ForMember(t => t.CragId, opt => opt.MapFrom(s => s.Sector!.Crag!.Id))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Sector!.Crag!.Name))
            .ForMember(t => t.AscentsCount, opt => opt.MapFrom(s => s.Ascents!.Count));

        CreateMap<CreateRouteCommand, Route>();
    }
}