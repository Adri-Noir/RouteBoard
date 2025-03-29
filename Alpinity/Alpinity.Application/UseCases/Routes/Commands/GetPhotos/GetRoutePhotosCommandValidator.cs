using FluentValidation;

namespace Alpinity.Application.UseCases.Routes.Commands.GetPhotos;

public class GetRoutePhotosCommandValidator : AbstractValidator<GetRoutePhotosCommand>
{
    public GetRoutePhotosCommandValidator()
    {
        RuleFor(x => x.RouteId)
            .NotEmpty()
            .WithMessage("Route ID is required");
    }
}