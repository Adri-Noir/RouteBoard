using FluentValidation;

namespace Alpinity.Application.UseCases.Sectors.Commands.Create;

public class CreateSectorCommandValidator: AbstractValidator<CreateSectorCommand>
{
    public CreateSectorCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Sector name is required")
            .MaximumLength(100).WithMessage("Sector name cannot exceed 100 characters");
        RuleFor(x => x.Description)
            .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters");
    }
}