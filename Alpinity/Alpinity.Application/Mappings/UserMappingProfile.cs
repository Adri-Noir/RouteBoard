using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class UserMappingProfile : Profile
{
    public UserMappingProfile()
    {
        CreateMap<User, UserProfileDto>()
            .ForMember(dest => dest.ProfilePhotoUrl, opt => opt.MapFrom(src => 
                src.ProfilePhoto != null ? src.ProfilePhoto.Url : null));
    }
} 