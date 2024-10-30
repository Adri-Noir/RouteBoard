using Alpinity.Application.UseCases.Search.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class SearchProfile : Profile
{
    public SearchProfile()
    {
        CreateMap<Sector, SearchResultItemDto>()
            .ForMember(t => t.Type, opt => opt.MapFrom(s => SearchResultItemType.Sector));
        
        CreateMap<Crag, SearchResultItemDto>()
            .ForMember(t => t.Type, opt => opt.MapFrom(s => SearchResultItemType.Crag));
        
        CreateMap<Route, SearchResultItemDto>()
            .ForMember(t => t.Type, opt => opt.MapFrom(s => SearchResultItemType.Route));
    }
}