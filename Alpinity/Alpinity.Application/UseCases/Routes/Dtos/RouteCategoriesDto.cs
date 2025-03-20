using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Routes.Dtos;

public class RouteCategoriesDto
{
    public ICollection<ClimbType>? ClimbTypes { get; set; }
    public ICollection<RockType>? RockTypes { get; set; }
    public ICollection<HoldType>? HoldTypes { get; set; }
}
