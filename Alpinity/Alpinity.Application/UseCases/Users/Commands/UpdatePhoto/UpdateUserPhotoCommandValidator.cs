using FluentValidation;
using Alpinity.Application.Helpers;

namespace Alpinity.Application.UseCases.Users.Commands.UpdatePhoto;

public class UpdateUserPhotoCommandValidator : AbstractValidator<UpdateUserPhotoCommand>
{
    public UpdateUserPhotoCommandValidator()
    {
        RuleFor(x => x.UserId)
            .NotEmpty();
        RuleFor(x => x.Photo)
            .NotNull()
            .Must(photo => ImageValidationHelper.ValidateFileSize(photo))
            .WithMessage("Photo must be less than 20MB in size")
            .Must(photo => ImageValidationHelper.ValidateImageResolution(photo))
            .WithMessage("Photo resolution is too high or the file is not a valid image");
    }
}