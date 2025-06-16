using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class AscentProfile : Profile
{
    public AscentProfile()
    {
        CreateMap<Ascent, AscentDto>()
            .ForMember(dest => dest.Username, opt => opt.MapFrom(src => src.User.Username))
            .ForMember(dest => dest.UserProfilePhoto, opt => opt.MapFrom(src => src.User.ProfilePhoto));

        CreateMap<Ascent, UserAscentDto>()
            .ForMember(dest => dest.AscentDate, opt => opt.MapFrom(src => src.AscentDate.ToString("yyyy-MM-dd")))
            .ForMember(dest => dest.RouteId, opt => opt.MapFrom(src => src.Route!.Id))
            .ForMember(dest => dest.RouteName, opt => opt.MapFrom(src => src.Route!.Name))
            .ForMember(dest => dest.RouteGrade, opt => opt.MapFrom(src => src.Route!.Grade))
            .ForMember(dest => dest.RouteDescription, opt => opt.MapFrom(src => src.Route!.Description))
            .ForMember(dest => dest.RouteLength, opt => opt.MapFrom(src => src.Route!.Length))
            .ForMember(dest => dest.RouteType, opt => opt.MapFrom(src => src.Route!.RouteType))
            .ForMember(dest => dest.SectorId, opt => opt.MapFrom(src => src.Route!.Sector!.Id))
            .ForMember(dest => dest.SectorName, opt => opt.MapFrom(src => src.Route!.Sector!.Name))
            .ForMember(dest => dest.CragId, opt => opt.MapFrom(src => src.Route!.Sector!.Crag!.Id))
            .ForMember(dest => dest.CragName, opt => opt.MapFrom(src => src.Route!.Sector!.Crag!.Name));
    }
}