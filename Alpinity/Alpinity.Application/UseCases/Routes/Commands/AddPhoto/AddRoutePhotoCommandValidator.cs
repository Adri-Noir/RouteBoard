using FluentValidation;

namespace Alpinity.Application.UseCases.Routes.Commands.AddPhoto;

public class AddRoutePhotoCommandValidator : AbstractValidator<AddRoutePhotoCommand>
{
    public AddRoutePhotoCommandValidator()
    {
        RuleFor(x => x.RouteId)
            .NotEmpty();
        RuleFor(x => x.Photo)
            .NotNull();
        RuleFor(x => x.LinePhoto)
            .NotNull();
    }
}