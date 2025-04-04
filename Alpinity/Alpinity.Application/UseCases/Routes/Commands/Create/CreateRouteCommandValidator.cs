using FluentValidation;

namespace Alpinity.Application.UseCases.Routes.Commands.Create;

public class CreateRouteCommandValidator : AbstractValidator<CreateRouteCommand>
{
    public CreateRouteCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Route name is required")
            .MaximumLength(100).WithMessage("Route name cannot exceed 100 characters");
        RuleFor(x => x.Description)
            .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters");
        RuleFor(x => x.Grade)
            .IsInEnum().WithMessage("Invalid climbing grade");
        RuleFor(x => x.SectorId)
            .NotEmpty().WithMessage("Sector ID is required");

        When(x => x.RouteType != null && x.RouteType.Any(), () =>
        {
            RuleForEach(x => x.RouteType)
                .IsInEnum().WithMessage("Invalid route type");
        });
        RuleFor(x => x.Length)
            .GreaterThan(0).WithMessage("Length must be greater than 0")
            .LessThan(10000).WithMessage("Length must be less than 10000");
    }
}