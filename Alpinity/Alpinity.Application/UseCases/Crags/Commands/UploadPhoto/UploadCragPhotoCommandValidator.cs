using FluentValidation;
using Alpinity.Application.Helpers;

namespace Alpinity.Application.UseCases.Crags.Commands.UploadPhoto;

public class UploadCragPhotoCommandValidator : AbstractValidator<UploadCragPhotoCommand>
{
    public UploadCragPhotoCommandValidator()
    {
        RuleFor(x => x.CragId)
            .NotEmpty();
        RuleFor(x => x.Photo)
            .NotNull()
            .Must(photo => ImageValidationHelper.ValidateFileSize(photo))
            .WithMessage("Photo must be less than 20MB in size")
            .Must(photo => ImageValidationHelper.ValidateImageResolution(photo))
            .WithMessage("Photo resolution is too high or the file is not a valid image");
    }
}