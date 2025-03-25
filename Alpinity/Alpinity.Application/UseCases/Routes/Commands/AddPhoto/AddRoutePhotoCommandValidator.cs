using FluentValidation;
using Alpinity.Application.Helpers;

namespace Alpinity.Application.UseCases.Routes.Commands.AddPhoto;

public class AddRoutePhotoCommandValidator : AbstractValidator<AddRoutePhotoCommand>
{
    public AddRoutePhotoCommandValidator()
    {
        RuleFor(x => x.RouteId)
            .NotEmpty();
        RuleFor(x => x.Photo)
            .NotNull()
            .Must(photo => ImageValidationHelper.ValidateFileSize(photo))
            .WithMessage("Photo must be less than 20MB in size")
            .Must(photo => ImageValidationHelper.ValidateImageResolution(photo))
            .WithMessage("Photo resolution is too high or the file is not a valid image");
        RuleFor(x => x.LinePhoto)
            .NotNull()
            .Must(photo => ImageValidationHelper.ValidateFileSize(photo))
            .WithMessage("Line photo must be less than 20MB in size")
            .Must(photo => ImageValidationHelper.ValidateImageResolution(photo))
            .WithMessage("Line photo resolution is too high or the file is not a valid image");
        RuleFor(x => x.CombinedPhoto)
            .NotNull()
            .Must(photo => ImageValidationHelper.ValidateFileSize(photo))
            .WithMessage("Combined photo must be less than 20MB in size")
            .Must(photo => ImageValidationHelper.ValidateImageResolution(photo))
            .WithMessage("Combined photo resolution is too high or the file is not a valid image");
        RuleFor(x => x)
            .Must(x => ImageValidationHelper.ValidateImagesHaveSameResolution(x.Photo, x.LinePhoto))
            .WithMessage("Photo and Line photo must have the same resolution")
            .Must(x => ImageValidationHelper.ValidateImagesHaveSameResolution(x.LinePhoto, x.CombinedPhoto))
            .WithMessage("Photo/Line Photo and Combined photo must have the same resolution");
    }
}