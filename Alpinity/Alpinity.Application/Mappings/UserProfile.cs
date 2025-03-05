using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class UserProfile : Profile
{
    public UserProfile()
    {
        CreateMap<User, UserDto>()
            .ForMember(t => t.ProfilePhotoUrl, opt => opt.MapFrom(s => s.ProfilePhoto.Url));

        CreateMap<User, LoggedInUserDto>()
            .ForMember(t => t.ProfilePhotoUrl, opt => opt.MapFrom(s => s.ProfilePhoto.Url));

        CreateMap<User, UserProfileDto>()
            .ForMember(dest => dest.ProfilePhotoUrl, opt => opt.MapFrom(src =>
                src.ProfilePhoto != null ? src.ProfilePhoto.Url : null))
            .ForMember(dest => dest.CragsVisited,
                opt => opt.MapFrom(src => src.Ascents!.Select(a => a.Route!.Sector!.Crag!).Distinct().Count()))
            .ForMember(dest => dest.RouteTypeAscentCount, opt => opt.MapFrom(src => src.Ascents!
                .Where(a => a.Route!.RouteType != null && a.Route.RouteType.Any())
                .SelectMany(a => a.Route!.RouteType!.Select(rt => new { RouteType = rt, Ascent = a }))
                .GroupBy(x => x.RouteType)
                .ToDictionary(g => g.Key,
                    g => g.GroupBy(x => x.Ascent.AscentType ?? AscentType.Redpoint)
                        .ToDictionary(ga => ga.Key, ga => ga.Count()))))
            .ForMember(dest => dest.ClimbingGradesCount, opt => opt.MapFrom(src => src.Ascents!
                .Where(a => a.Route != null)
                .GroupBy(a => a.Route!.Grade ?? ClimbingGrade.PROJECT)
                .ToDictionary(g => g.Key, g => g.Count())))
            .ForMember(dest => dest.Photos,
                opt => opt.MapFrom(src => src.UserPhotoGallery!.Select(p => p.Url).ToList()));
    }
}