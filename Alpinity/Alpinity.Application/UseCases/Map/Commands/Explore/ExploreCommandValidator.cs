using System;
using FluentValidation;

namespace Alpinity.Application.UseCases.Map.Commands.Explore;

public class ExploreCommandValidator : AbstractValidator<ExploreCommand>
{
    public ExploreCommandValidator()
    {
        RuleFor(x => x.Latitude)
            .Must((latitude) => latitude == null || (latitude >= -90 && latitude <= 90))
            .WithMessage("Latitude must be a valid latitude value");

        RuleFor(x => x.Longitude)
            .Must((longitude) => longitude == null || (longitude >= -180 && longitude <= 180))
            .WithMessage("Longitude must be a valid longitude value");

        RuleFor(x => x.Radius)
            .Must((radius) => radius == null || (radius >= 0 && radius <= 100000))
            .WithMessage("Radius must be a valid radius value");
    }

}
