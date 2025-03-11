using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Sectors.Commands.Create;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.Mappings;

public class SectorProfile: Profile
{
    public SectorProfile()
    {
        CreateMap<Sector, SectorSimpleDto>()
            .ForMember(t => t.Photo, opt => opt.MapFrom(s => s.Photos.FirstOrDefault().Url));

        CreateMap<Sector, SectorDetailedDto>()
            .ForMember(t => t.Photos, opt => opt.MapFrom(s => s.Photos.Select(p => p.Url)))
            .ForMember(t => t.CragId, opt => opt.MapFrom(s => s.Crag.Id))
            .ForMember(t => t.CragName, opt => opt.MapFrom(s => s.Crag.Name))
            .ForMember(t => t.Location, opt => opt.MapFrom(s => s.Location));

        CreateMap<CreateSectorCommand, Sector>()
            .ForMember(t => t.Location, opt => opt.MapFrom(s => s.Location));
    }
}