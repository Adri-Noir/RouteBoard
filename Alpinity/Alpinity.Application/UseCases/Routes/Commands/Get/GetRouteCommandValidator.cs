using FluentValidation;

namespace Alpinity.Application.UseCases.Routes.Commands.Get;

public class GetRouteCommandValidator : AbstractValidator<GetRouteCommand>
{
    public GetRouteCommandValidator()
    {
        RuleFor(x => x.Id).NotEmpty().WithMessage("Route ID is required");
    }
}
