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
            .ForMember(dest => dest.UserProfilePhotoUrl, opt =>
                opt.MapFrom(src => src.User.ProfilePhoto != null ? src.User.ProfilePhoto.Url : null));
    }
}