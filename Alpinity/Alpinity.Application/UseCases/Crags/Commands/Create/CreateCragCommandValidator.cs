using FluentValidation;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommandValidator : AbstractValidator<CreateCragCommand>
{
    public CreateCragCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(100);
        RuleFor(x => x.Description)
            .MaximumLength(1000);
        RuleFor(x => x.Location.Latitude)
            .InclusiveBetween(-90, 90);
        RuleFor(x => x.Location.Longitude)
            .InclusiveBetween(-180, 180);
            
    }
}