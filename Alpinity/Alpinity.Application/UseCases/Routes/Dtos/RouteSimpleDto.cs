namespace Alpinity.Application.UseCases.Routes.Dtos;

public class RouteSimpleDto
{
    public required Guid Id { get; set; }
    public required string Name { get; set; }
    public string Description { get; set; } = null!;
    public string Photo { get; set; } = null!;
    public string Grade { get; set; } = null!;
}