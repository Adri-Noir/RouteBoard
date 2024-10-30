using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class RouteProfile: Profile
{
    public RouteProfile()
    {
        CreateMap<Route, RouteSimpleDto>()
            .ForMember(t => t.Photo, opt => opt.MapFrom(s => s.RoutePhotos.FirstOrDefault().Image.Url));
    }
}