using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;

namespace Alpinity.Application.Mappings;

public class PhotoProfile : Profile
{
    public PhotoProfile()
    {
        CreateMap<RoutePhoto, RoutePhotoDto>()
            .ForMember(t => t.RouteId, opt => opt.MapFrom(s => s.RouteId))
            .ForMember(t => t.CombinedPhoto, opt => opt.MapFrom(s => s.CombinedPhoto));

        CreateMap<Photo, PhotoDto>()
            .ForMember(t => t.TakenAt,
                opt => opt.MapFrom(s =>
                    s.TakenAt.ToString("s")))
            .ForMember(t => t.Url,
                opt => opt.ConvertUsing<TemporaryUrlResolver, string>(s => s.Url));

        CreateMap<RoutePhoto, ExtendedRoutePhotoDto>()
            .ForMember(t => t.RouteId, opt => opt.MapFrom(s => s.RouteId))
            .ForMember(t => t.Image, opt => opt.MapFrom(s => s.Image))
            .ForMember(t => t.PathLine, opt => opt.MapFrom(s => s.PathLine));
    }
}

// Custom value resolver for temporary URLs
public class TemporaryUrlResolver : IValueConverter<string, string>
{
    private readonly IFileRepository _fileRepository;

    public TemporaryUrlResolver(IFileRepository fileRepository)
    {
        _fileRepository = fileRepository;
    }

    public string Convert(string sourceBlobName, ResolutionContext context)
    {
        // Check if this is already a URL (for backward compatibility)
        if (sourceBlobName.StartsWith("http"))
            return sourceBlobName;

        // If it's just a blob name, generate a temporary URL with 1 hour validity
        return _fileRepository.GetTemporaryUrl(sourceBlobName, TimeSpan.FromHours(1));
    }
}