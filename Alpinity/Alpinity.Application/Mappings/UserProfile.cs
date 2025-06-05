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
        CreateMap<User, UserDto>();

        CreateMap<User, UserRestrictedDto>();

        CreateMap<User, LoggedInUserDto>()
            .ForMember(t => t.Role, opt => opt.MapFrom(s => s.UserRole));

        CreateMap<User, UserProfileDto>()
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
                .Where(a => a.Route != null)
                .GroupBy(a => a.Route!.Grade ?? ClimbingGrade.PROJECT)
                .Select(g => new GradeCountDto { ClimbingGrade = g.Key, Count = g.Count() })
                .ToList()))
            .ForMember(dest => dest.Photos,
                opt => opt.MapFrom(src => src.UserPhotoGallery!.Select(p => p.Url).ToList()));

    }
}