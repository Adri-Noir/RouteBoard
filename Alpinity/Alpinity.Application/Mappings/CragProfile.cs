using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class CragProfile: Profile
{
    public CragProfile()
    {
        CreateMap<Crag, CragDetailedDto>()
            .ForMember(t => t.Photos, opt => opt.MapFrom(s => s.Photos.Select(p => p.Url)));
    }
}