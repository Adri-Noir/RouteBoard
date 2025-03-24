using FluentValidation;
using Alpinity.Application.Helpers;

namespace Alpinity.Application.UseCases.Sectors.Commands.UploadPhoto;

public class UploadSectorPhotoCommandValidator : AbstractValidator<UploadSectorPhotoCommand>
{
    public UploadSectorPhotoCommandValidator()
    {
        RuleFor(x => x.SectorId)
            .NotEmpty();
        RuleFor(x => x.Photo)
            .NotNull()
            .Must(photo => ImageValidationHelper.ValidateFileSize(photo))
            .WithMessage("Photo must be less than 20MB in size")
            .Must(photo => ImageValidationHelper.ValidateImageResolution(photo))
            .WithMessage("Photo resolution is too high or the file is not a valid image");
    }
}