using Alpinity.Application.Helpers;
using FluentValidation;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Routes.Commands.Edit;

public class EditRouteCommandValidator : AbstractValidator<EditRouteCommand>
{
    private const int MaxPhotos = 10;

    public EditRouteCommandValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty()
            .WithMessage("Route ID is required.");

        When(x => x.Name != null, () =>
        {
            RuleFor(x => x.Name)
                .MinimumLength(3).WithMessage("Route name must be at least 3 characters long.")
                .MaximumLength(100).WithMessage("Route name cannot exceed 100 characters.");
        });

        When(x => x.Description != null, () =>
        {
            RuleFor(x => x.Description)
                .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters.");
        });

        When(x => x.Grade != null, () =>
        {
            RuleFor(x => x.Grade)
                .IsInEnum().WithMessage("Invalid climbing grade");
        });

        When(x => x.RouteType != null && x.RouteType.Any(), () =>
        {
            RuleForEach(x => x.RouteType)
                .IsInEnum().WithMessage("Invalid route type");
        });

        When(x => x.Length != null, () =>
        {
            RuleFor(x => x.Length)
                .GreaterThan(0).WithMessage("Length must be greater than 0")
                .LessThan(10000).WithMessage("Length must be less than 10000");
        });


        When(x => x.PhotosToRemove != null, () =>
        {
            RuleFor(x => x.PhotosToRemove)
                .Must(list => list == null || list.Count <= MaxPhotos)
                .WithMessage($"You can remove a maximum of {MaxPhotos} photos.")
                .Must(list => list == null || list.Distinct().Count() == list.Count)
                .WithMessage("Duplicate photo IDs to remove are not allowed.");
        });
    }
}