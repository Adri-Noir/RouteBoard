using Alpinity.Application.UseCases.Search.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class SearchHistoryProfile : Profile
{
    public SearchHistoryProfile()
    {
        CreateMap<SearchHistory, SearchResultDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.EntityType == SearchResultItemType.Crag ? src.CragId :
                src.EntityType == SearchResultItemType.Sector ? src.SectorId :
                src.EntityType == SearchResultItemType.Route ? src.RouteId :
                src.EntityType == SearchResultItemType.UserProfile ? src.ProfileUserId : null))
            .ForMember(dest => dest.EntityType, opt => opt.MapFrom(src => src.EntityType))

            // Crag information
            .ForMember(dest => dest.CragId, opt => opt.MapFrom(src =>
                src.CragId))

            .ForMember(dest => dest.CragName, opt => opt.MapFrom(src =>
                src.Crag != null ? src.Crag.Name : null))

            .ForMember(dest => dest.CragLocation, opt => opt.MapFrom(src =>
                src.Crag != null ? src.Crag.Location : null))

            .ForMember(dest => dest.CragRoutesCount, opt => opt.MapFrom(src =>
                src.Crag != null && src.Crag.Sectors != null ? src.Crag.Sectors.Sum(s => s.Routes.Count) : 0))

            .ForMember(dest => dest.CragSectorsCount, opt => opt.MapFrom(src =>
                src.Crag != null && src.Crag.Sectors != null ? src.Crag.Sectors.Count : 0))

            // Sector information
            .ForMember(dest => dest.SectorId, opt => opt.MapFrom(src =>
                src.SectorId))

            .ForMember(dest => dest.SectorName, opt => opt.MapFrom(src =>
                src.Sector != null ? src.Sector.Name : null))

            .ForMember(dest => dest.SectorCragId, opt => opt.MapFrom(src =>
                (object)(src.Sector != null && src.Sector.Crag != null ? src.Sector.Crag.Id : (Guid?)null)))

            .ForMember(dest => dest.SectorCragName, opt => opt.MapFrom(src =>
                src.Sector != null && src.Sector.Crag != null ? src.Sector.Crag.Name : null))

            .ForMember(dest => dest.SectorRoutesCount, opt => opt.MapFrom(src =>
                src.Sector != null && src.Sector.Routes != null ? src.Sector.Routes.Count : 0))

            // Route information
            .ForMember(dest => dest.RouteId, opt => opt.MapFrom(src =>
                src.RouteId))

            .ForMember(dest => dest.RouteName, opt => opt.MapFrom(src =>
                src.Route != null ? src.Route.Name : null))

            .ForMember(dest => dest.RouteDifficulty, opt => opt.MapFrom(src =>
                src.Route != null && src.Route.Grade.HasValue ? src.Route.Grade : null))

            .ForMember(dest => dest.RouteAscentsCount, opt => opt.MapFrom(src =>
                src.Route != null && src.Route.Ascents != null ? src.Route.Ascents.Count : 0))

            .ForMember(dest => dest.RouteSectorId, opt => opt.MapFrom(src =>
                (object)(src.Route != null && src.Route.Sector != null ? src.Route.Sector.Id : (Guid?)null)))

            .ForMember(dest => dest.RouteSectorName, opt => opt.MapFrom(src =>
                src.Route != null && src.Route.Sector != null ? src.Route.Sector.Name : null))

            .ForMember(dest => dest.RouteCragId, opt => opt.MapFrom(src =>
                (object)(src.Route != null && src.Route.Sector != null && src.Route.Sector.Crag != null ? src.Route.Sector.Crag.Id : (Guid?)null)))

            .ForMember(dest => dest.RouteCragName, opt => opt.MapFrom(src =>
                src.Route != null && src.Route.Sector != null && src.Route.Sector.Crag != null ? src.Route.Sector.Crag.Name : null))

            // User profile information
            .ForMember(dest => dest.ProfileUserId, opt => opt.MapFrom(src =>
                src.ProfileUserId))

            .ForMember(dest => dest.ProfileUsername, opt => opt.MapFrom(src =>
                src.ProfileUser != null ? src.ProfileUser.Username : null));
    }
}