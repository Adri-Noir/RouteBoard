using FluentValidation;

namespace Alpinity.Application.UseCases.Crags.Commands;

public class DeleteCragCommandValidator : AbstractValidator<DeleteCragCommand>
{
    public DeleteCragCommandValidator()
    {
        RuleFor(x => x.CragId)
            .NotEmpty().WithMessage("Crag ID is required");
    }
}