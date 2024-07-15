using Alpinity.Application.Dtos;
using AutoMapper;
using NetTopologySuite;
using NetTopologySuite.Geometries;

namespace Alpinity.Application.Mappings;

public class PointProfile: Profile
{
    public PointProfile()
    {
        
        CreateMap<Point, PointDto>()
            .ForMember(t => t.Latitude, opt => opt.MapFrom(s => s.Y))
            .ForMember(t => t.Longitude, opt => opt.MapFrom(s => s.X));
        
        CreateMap<PointDto, Point>()
            .ConstructUsing(dto => NtsGeometryServices.Instance.CreateGeometryFactory(4326).CreatePoint(new Coordinate(dto.Longitude, dto.Latitude)));
    }
}