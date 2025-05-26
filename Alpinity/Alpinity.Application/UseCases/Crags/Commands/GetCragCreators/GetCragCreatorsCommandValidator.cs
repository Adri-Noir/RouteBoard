using FluentValidation;

namespace Alpinity.Application.UseCases.Crags.Commands.GetCragCreators;

public class GetCragCreatorsCommandValidator : AbstractValidator<GetCragCreatorsCommand>
{
    public GetCragCreatorsCommandValidator()
    {
        RuleFor(x => x.CragId)
            .NotEmpty()
            .WithMessage("Crag ID is required.");
    }
}