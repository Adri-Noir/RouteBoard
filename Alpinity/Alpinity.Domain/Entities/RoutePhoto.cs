namespace Alpinity.Domain.Entities;

public class RoutePhoto
{
    public Guid Id { get; set; }
    public Guid RouteId { get; set; }
    public Route? Route { get; set; }

    public Guid ImageId { get; set; }
    public Photo? Image { get; set; }
    public Guid PathLineId { get; set; }
    public Photo? PathLine { get; set; }
}