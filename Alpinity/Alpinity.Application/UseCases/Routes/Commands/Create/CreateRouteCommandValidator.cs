using FluentValidation;

namespace Alpinity.Application.UseCases.Routes.Commands.Create;

public class CreateRouteCommandValidator : AbstractValidator<CreateRouteCommand>
{
    public CreateRouteCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(100);
        RuleFor(x => x.Description)
            .MaximumLength(1000);
        RuleFor(x => x.Grade)
            .MaximumLength(100);
        RuleFor(x => x.SectorId)
            .NotEmpty();
    }
}