using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Entities;
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
                src.ProfilePhoto != null ? src.ProfilePhoto.Url : null));
    }
}