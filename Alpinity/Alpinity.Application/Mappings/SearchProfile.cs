using Alpinity.Application.UseCases.Search.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class SearchProfile : Profile
{
    public SearchProfile()
    {
        CreateMap<Sector, SearchResultDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.EntityType, opt => opt.MapFrom(src => SearchResultItemType.Sector))
            // Sector information
            .ForMember(dest => dest.SectorId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.SectorName, opt => opt.MapFrom(src => src.Name))
            .ForMember(dest => dest.SectorCragId, opt => opt.MapFrom(src =>
                src.Crag != null ? src.Crag.Id : (Guid?)null))
            .ForMember(dest => dest.SectorCragName, opt => opt.MapFrom(src =>
                src.Crag != null ? src.Crag.Name : null))
            .ForMember(dest => dest.SectorRoutesCount, opt => opt.MapFrom(src =>
                src.Routes != null ? src.Routes.Count : 0));

        CreateMap<Crag, SearchResultDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.EntityType, opt => opt.MapFrom(src => SearchResultItemType.Crag))
            // Crag information
            .ForMember(dest => dest.CragId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.CragName, opt => opt.MapFrom(src => src.Name))
            .ForMember(dest => dest.CragLocation, opt => opt.MapFrom(src => src.Location))
            .ForMember(dest => dest.CragSectorsCount, opt => opt.MapFrom(src =>
                src.Sectors != null ? src.Sectors.Count : 0))
            .ForMember(dest => dest.CragRoutesCount, opt => opt.MapFrom(src =>
                src.Sectors != null ? src.Sectors.Sum(s => s.Routes != null ? s.Routes.Count : 0) : 0));

        CreateMap<Route, SearchResultDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.EntityType, opt => opt.MapFrom(src => SearchResultItemType.Route))
            // Route information
            .ForMember(dest => dest.RouteId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.RouteName, opt => opt.MapFrom(src => src.Name))
            .ForMember(dest => dest.RouteDifficulty, opt => opt.MapFrom(src =>
                src.Grade.HasValue ? src.Grade : null))
            .ForMember(dest => dest.RouteAscentsCount, opt => opt.MapFrom(src =>
                src.Ascents != null ? src.Ascents.Count : 0))
            .ForMember(dest => dest.RouteSectorId, opt => opt.MapFrom(src =>
                src.Sector != null ? src.Sector.Id : (Guid?)null))
            .ForMember(dest => dest.RouteSectorName, opt => opt.MapFrom(src =>
                src.Sector != null ? src.Sector.Name : null))
            .ForMember(dest => dest.RouteCragId, opt => opt.MapFrom(src =>
                src.Sector != null && src.Sector.Crag != null ? src.Sector.Crag.Id : (Guid?)null))
            .ForMember(dest => dest.RouteCragName, opt => opt.MapFrom(src =>
                src.Sector != null && src.Sector.Crag != null ? src.Sector.Crag.Name : null));

        CreateMap<User, SearchResultDto>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.EntityType, opt => opt.MapFrom(src => SearchResultItemType.UserProfile))
            .ForMember(dest => dest.ProfileUsername, opt => opt.MapFrom(src => src.Username))
            .ForMember(dest => dest.ProfileUserId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.ProfilePhotoUrl, opt => opt.MapFrom(src => src.ProfilePhoto != null ? src.ProfilePhoto.Url : null))
            .ForMember(dest => dest.AscentsCount, opt => opt.MapFrom(src => src.Ascents!.Count()));
    }
}