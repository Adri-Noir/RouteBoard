using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Domain.Entities;
using AutoMapper;
using Microsoft.Extensions.Caching.Memory;

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

        CreateMap<RoutePhoto, DetectRoutePhotoDto>();

        CreateMap<RoutePhoto, AllRoutePhotoDto>();
    }
}

// Custom value resolver for temporary URLs
public class TemporaryUrlResolver : IValueConverter<string, string>
{
    private readonly IFileRepository _fileRepository;
    private readonly IMemoryCache _memoryCache;

    // How long the generated SAS is valid for
    private static readonly TimeSpan SasValidity = TimeSpan.FromHours(6);

    // We cache the URL slightly shorter than its validity to avoid serving an expired link
    private static readonly TimeSpan CacheTtl = TimeSpan.FromHours(5);

    public TemporaryUrlResolver(IFileRepository fileRepository, IMemoryCache memoryCache)
    {
        _fileRepository = fileRepository;
        _memoryCache = memoryCache;
    }

    public string Convert(string sourceBlobName, ResolutionContext context)
    {
        if (string.IsNullOrWhiteSpace(sourceBlobName))
            return sourceBlobName;

        // Already a URL (e.g. migrated/public images)
        if (sourceBlobName.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            return sourceBlobName;

        return _memoryCache.GetOrCreate(sourceBlobName, entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheTtl;
            return _fileRepository.GetTemporaryUrl(sourceBlobName, SasValidity);
        });
    }
}