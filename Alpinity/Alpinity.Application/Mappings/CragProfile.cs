using Alpinity.Application.UseCases.Crags.Commands.Edit;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Application.UseCases.Map.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class CragProfile : Profile
{
    public CragProfile()
    {
        CreateMap<Crag, CragDetailedDto>();

        CreateMap<Crag, ExploreDto>()
            .ForMember(t => t.CragId, opt => opt.MapFrom(s => s.Id))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Name))
            .ForMember(t => t.CragDescription, opt => opt.MapFrom(s => s.Description))
            .ForMember(t => t.Photo, opt => opt.MapFrom(s => s.Photos.FirstOrDefault()))
            .ForMember(t => t.SectorsCount, opt => opt.MapFrom(s => s.Sectors.Count))
            .ForMember(t => t.RoutesCount, opt => opt.MapFrom(s => s.Sectors.Sum(s => s.Routes.Count)))
            .ForMember(t => t.AscentsCount, opt => opt.MapFrom(s => s.Sectors.Sum(s => s.Routes.Sum(r => r.Ascents.Count))));

        CreateMap<Crag, GlobeResponseDto>()
        .ForMember(t => t.ImageUrl, opt => opt.MapFrom(s => s.Photos != null && s.Photos.Any() ? s.Photos.First().Url : null));

        CreateMap<EditCragCommand, Crag>()
            .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
    }
}