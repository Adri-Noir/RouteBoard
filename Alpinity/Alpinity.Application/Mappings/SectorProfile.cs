using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Application.UseCases.Map.Dtos;
using Alpinity.Application.UseCases.Routes.Dtos;
using Alpinity.Application.UseCases.Sectors.Commands.Create;
using Alpinity.Application.UseCases.Sectors.Commands.Edit;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class SectorProfile : Profile
{
    public SectorProfile()
    {
        CreateMap<Sector, SectorSimpleDto>()
            .ForMember(t => t.Photo, opt => opt.MapFrom(s => s.Photos.FirstOrDefault().Url));

        CreateMap<Sector, SectorDetailedDto>()
            .ForMember(t => t.CragId, opt => opt.MapFrom(s => s.Crag.Id))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Crag.Name));

        CreateMap<CreateSectorCommand, Sector>();

        CreateMap<Sector, CragSectorDto>()
            .ForMember(t => t.Photo, opt => opt.MapFrom(s => s.Photos.FirstOrDefault()))
            .ForMember(t => t.RoutesCount, opt => opt.MapFrom(s => s.Routes != null ? s.Routes.Count : 0));

        CreateMap<Sector, GlobeSectorResponseDto>()
            .ForMember(t => t.ImageUrl, opt => opt.MapFrom(s => s.Photos != null && s.Photos.Any() ? s.Photos.First().Url : null));

        CreateMap<EditSectorCommand, Sector>()
            .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
    }
}