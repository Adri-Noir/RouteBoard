using Alpinity.Application.Helpers;
using FluentValidation;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommandValidator : AbstractValidator<CreateCragCommand>
{
    private const int MaxPhotos = 10;

    public CreateCragCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Crag name is required")
            .MinimumLength(3).WithMessage("Crag name must be at least 3 characters")
            .MaximumLength(100).WithMessage("Crag name cannot exceed 100 characters");
        RuleFor(x => x.Description)
            .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters");

        RuleFor(x => x.Photos)
            .Must(photos => photos == null || photos.Count <= MaxPhotos)
            .WithMessage($"You can upload a maximum of {MaxPhotos} photos.")
            .ForEach(photoRule =>
            {
                photoRule.Cascade(CascadeMode.Stop);

                photoRule.Must(f => ImageValidationHelper.ValidateFileSize(f))
                    .WithMessage($"Photo size must be between 0 and {ImageValidationHelper.MaxFileSizeBytes / 1024 / 1024}MB.");

                photoRule.Must(f => ImageValidationHelper.HasAllowedExtension(f.FileName))
                    .WithMessage($"Invalid photo format. Allowed formats: {string.Join(", ", ImageValidationHelper.AllowedImageExtensions)}.");

                photoRule.Must(f => ImageValidationHelper.HasAllowedContentType(f.ContentType))
                    .WithMessage($"Invalid photo content type. Allowed types: {string.Join(", ", ImageValidationHelper.AllowedImageContentTypes)}.");
            });
    }
}