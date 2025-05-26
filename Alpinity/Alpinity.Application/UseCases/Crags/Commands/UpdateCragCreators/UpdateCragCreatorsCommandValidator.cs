using FluentValidation;

namespace Alpinity.Application.UseCases.Crags.Commands.UpdateCragCreators;

public class UpdateCragCreatorsCommandValidator : AbstractValidator<UpdateCragCreatorsCommand>
{
    public UpdateCragCreatorsCommandValidator()
    {
        RuleFor(x => x.CragId)
            .NotEmpty()
            .WithMessage("Crag ID is required.");

        RuleFor(x => x.UserIds)
            .NotNull()
            .WithMessage("User IDs collection is required.");

        RuleForEach(x => x.UserIds)
            .NotEmpty()
            .WithMessage("User ID cannot be empty.");
    }
}