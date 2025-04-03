using FluentValidation;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommandValidator : AbstractValidator<CreateCragCommand>
{
    public CreateCragCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Crag name is required")
            .MinimumLength(3).WithMessage("Crag name must be at least 3 characters")
            .MaximumLength(100).WithMessage("Crag name cannot exceed 100 characters");
        RuleFor(x => x.Description)
            .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters");
    }
}