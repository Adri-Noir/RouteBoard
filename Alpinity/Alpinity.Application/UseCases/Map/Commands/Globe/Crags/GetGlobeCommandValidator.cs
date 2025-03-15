using System;
using FluentValidation;

namespace Alpinity.Application.UseCases.Map.Commands.Globe;

public class GetGlobeCommandValidator : AbstractValidator<GetGlobeCommand>
{
    public GetGlobeCommandValidator()
    {
        RuleFor(x => x.NorthEast).NotEmpty().WithMessage("NorthEast is required");
        RuleFor(x => x.SouthWest).NotEmpty().WithMessage("SouthWest is required");
        RuleFor(x => x.NorthEast.Latitude).LessThan(90).WithMessage("NorthEast latitude must be less than 90");
        RuleFor(x => x.NorthEast.Longitude).LessThan(180).WithMessage("NorthEast longitude must be less than 180");
        RuleFor(x => x.SouthWest.Latitude).GreaterThan(-90).WithMessage("SouthWest latitude must be greater than -90");
        RuleFor(x => x.SouthWest.Longitude).GreaterThan(-180).WithMessage("SouthWest longitude must be greater than -180");
    }
}
