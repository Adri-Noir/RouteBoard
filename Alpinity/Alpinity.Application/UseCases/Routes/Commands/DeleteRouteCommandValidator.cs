using FluentValidation;

namespace Alpinity.Application.UseCases.Routes.Commands;

public class DeleteRouteCommandValidator : AbstractValidator<DeleteRouteCommand>
{
    public DeleteRouteCommandValidator()
    {
        RuleFor(x => x.RouteId)
            .NotEmpty().WithMessage("Route ID is required");
    }
}