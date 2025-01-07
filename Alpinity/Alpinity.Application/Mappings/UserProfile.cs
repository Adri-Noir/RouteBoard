using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class UserProfile : Profile
{
    public UserProfile()
    {
        CreateMap<User, UserDto>()
            .ForMember(t => t.ProfilePhotoUrl, opt => opt.MapFrom(s => s.ProfilePhoto.Url))
            .ForMember(t => t.CreatedAt, opt => opt.MapFrom(s => s.CreatedAt.ToString("s")));
        CreateMap<User, LoggedInUserDto>()
            .ForMember(t => t.ProfilePhotoUrl, opt => opt.MapFrom(s => s.ProfilePhoto.Url));
    }
}