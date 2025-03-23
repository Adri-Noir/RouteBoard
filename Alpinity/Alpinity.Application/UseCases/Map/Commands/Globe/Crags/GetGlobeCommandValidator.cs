using FluentValidation;

namespace Alpinity.Application.UseCases.Map.Commands.Globe.Crags;

public class GetGlobeCommandValidator : AbstractValidator<GetGlobeCommand>
{
    public GetGlobeCommandValidator()
    {
        RuleFor(x => x.NorthEast).NotEmpty().WithMessage("NorthEast is required");
        RuleFor(x => x.SouthWest).NotEmpty().WithMessage("SouthWest is required");
        RuleFor(x => x.NorthEast.Latitude).LessThanOrEqualTo(90).WithMessage("NorthEast latitude must be less than or equal to 90");
        RuleFor(x => x.NorthEast.Longitude).LessThanOrEqualTo(180).WithMessage("NorthEast longitude must be less than or equal to 180");
        RuleFor(x => x.SouthWest.Latitude).GreaterThanOrEqualTo(-90).WithMessage("SouthWest latitude must be greater than or equal to -90");
        RuleFor(x => x.SouthWest.Longitude).GreaterThanOrEqualTo(-180).WithMessage("SouthWest longitude must be greater than or equal to -180");
    }
}