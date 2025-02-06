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
            .IsInEnum();
        RuleFor(x => x.SectorId)
            .NotEmpty();
        RuleFor(x => x.RouteType)
            .IsInEnum();
        RuleFor(x => x.Length)
            .GreaterThan(0)
            .LessThan(10000);
    }
}