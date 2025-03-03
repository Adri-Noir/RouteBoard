using System;
using Alpinity.Application.Dtos;
using Alpinity.Application.UseCases.Photos.Dtos;

namespace Alpinity.Application.UseCases.Map.Dtos;

public class ExploreDto
{
    public required Guid Id { get; set; }
    public string? CragId { get; set; }
    public string? CragName { get; set; }
    public string? CragDescription { get; set; }
    public PointDto? Location { get; set; }
    public string? LocationName { get; set; }
    public PhotoDto? Photo { get; set; }
    public int? SectorsCount { get; set; }
    public int? RoutesCount { get; set; }
    public int? AscentsCount { get; set; }
}
