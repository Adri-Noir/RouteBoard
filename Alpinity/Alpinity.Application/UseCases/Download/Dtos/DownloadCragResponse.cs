namespace Alpinity.Application.UseCases.Download.Dtos;

using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Photos.Dtos;
using Alpinity.Application.UseCases.Routes.Dtos;

public class DownloadCragResponse
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public string? LocationName { get; set; }
    public ICollection<DownloadSectorResponse> Sectors { get; set; }
    public ICollection<PhotoDto> Photos { get; set; }
}

public class DownloadSectorResponse
{
    public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string Description { get; set; } = null!;
    public PointDto? Location { get; set; }
    public ICollection<PhotoDto> Photos { get; set; } = null!;
    public ICollection<DownloadRouteResponse> Routes { get; set; } = null!;
    public Guid CragId { get; set; }
    public string CragName { get; set; } = null!;
}