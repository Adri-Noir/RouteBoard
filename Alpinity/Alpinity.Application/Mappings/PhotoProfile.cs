using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class PhotoProfile : Profile
{
    public PhotoProfile()
    {
        CreateMap<RoutePhoto, RoutePhotoDto>()
            .ForMember(t => t.Image, opt => opt.MapFrom(s => s.Image))
            .ForMember(t => t.PathLine, opt => opt.MapFrom(s => s.PathLine));

        CreateMap<Photo, PhotoDto>()
            .ForMember(t => t.TakenAt,
                opt => opt.MapFrom(s =>
                    s.TakenAt.ToString("s")));
    }
}