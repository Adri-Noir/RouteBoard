using Alpinity.Application.UseCases.Search.Dtos;
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
                .Select(g => new RouteTypeAscentCountDto
                {
                    RouteType = g.Key,
                    AscentCount = g.GroupBy(x => x.Ascent.AscentType ?? AscentType.Redpoint)
                        .Select(ga => new AscentCountDto { AscentType = ga.Key, Count = ga.Count() })
                        .ToList()
                })
                .ToList()))
            .ForMember(dest => dest.ClimbingGradeAscentCount, opt => opt.MapFrom(src => src.Ascents!
                .Where(a => a.Route != null && a.Route.RouteType != null && a.Route.RouteType.Any())
                .SelectMany(a => a.Route!.RouteType!.Select(rt => new { RouteType = rt, Ascent = a }))
                .GroupBy(x => x.RouteType)
                .Select(g => new ClimbingGradeAscentCountDto
                {
                    RouteType = g.Key,
                    GradeCount = g.GroupBy(x => x.Ascent.Route!.Grade ?? ClimbingGrade.PROJECT)
                        .Select(ga => new GradeCountDto { ClimbingGrade = ga.Key, Count = ga.Count() })
                        .ToList()
                })
                .ToList()))
            .ForMember(dest => dest.Photos,
                opt => opt.MapFrom(src => src.UserPhotoGallery!.Select(p => p.Url).ToList()));

    }
}