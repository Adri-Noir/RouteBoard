using FluentValidation;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommandValidator : AbstractValidator<CreateCragCommand>
{
    public CreateCragCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Crag name is required")
            .MaximumLength(100).WithMessage("Crag name cannot exceed 100 characters");
        RuleFor(x => x.Description)
            .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters");
        RuleFor(x => x.Location.Latitude)
            .InclusiveBetween(-90, 90).WithMessage("Latitude must be between -90 and 90");
        RuleFor(x => x.Location.Longitude)
            .InclusiveBetween(-180, 180).WithMessage("Longitude must be between -180 and 180");
            
    }
}