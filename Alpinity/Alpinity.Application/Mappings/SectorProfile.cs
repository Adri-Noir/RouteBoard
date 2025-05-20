using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Application.UseCases.Download.Dtos;
using Alpinity.Application.UseCases.Map.Dtos;
using Alpinity.Application.UseCases.Sectors.Commands.Create;
using Alpinity.Application.UseCases.Sectors.Commands.Edit;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class SectorProfile : Profile
{
    public SectorProfile()
    {
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

        CreateMap<Sector, DownloadSectorResponse>()
            .ForMember(dest => dest.CragId, opt => opt.MapFrom(src => src.Crag.Id))
            .ForMember(dest => dest.CragName, opt => opt.MapFrom(src => src.Crag.Name));
    }
}