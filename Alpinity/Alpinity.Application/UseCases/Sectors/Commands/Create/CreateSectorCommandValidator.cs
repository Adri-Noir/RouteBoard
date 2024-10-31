using FluentValidation;

namespace Alpinity.Application.UseCases.Sectors.Create;

public class CreateSectorCommandValidator: AbstractValidator<CreateSectorCommand>
{
    public CreateSectorCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(100);
        RuleFor(x => x.Description)
            .MaximumLength(1000);
    }
}