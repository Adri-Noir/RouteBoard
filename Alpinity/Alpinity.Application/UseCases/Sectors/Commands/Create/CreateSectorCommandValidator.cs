using Alpinity.Application.Helpers;
using FluentValidation;

namespace Alpinity.Application.UseCases.Sectors.Commands.Create;

public class CreateSectorCommandValidator : AbstractValidator<CreateSectorCommand>
{
    private const int MaxPhotos = 10;

    public CreateSectorCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Sector name is required.")
            .MinimumLength(3).WithMessage("Sector name must be at least 3 characters long.")
            .MaximumLength(100).WithMessage("Sector name cannot exceed 100 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters.");

        RuleFor(x => x.CragId)
            .NotEmpty().WithMessage("Crag ID is required.");

        // Validation for Location can be added here if needed, e.g., checking range
        // RuleFor(x => x.Location).NotNull().WithMessage("Location is required.");

        RuleFor(x => x.Photos)
            .Must(photos => photos == null || photos.Count <= MaxPhotos)
            .WithMessage($"You can upload a maximum of {MaxPhotos} photos.")
            .ForEach(photoRule =>
            {
                photoRule.Cascade(CascadeMode.Stop); // Stop on first failure for a single photo

                photoRule.Must(f => ImageValidationHelper.ValidateFileSize(f))
                    .WithMessage($"Photo size must be between 0 and {ImageValidationHelper.MaxFileSizeBytes / 1024 / 1024}MB.");

                photoRule.Must(f => ImageValidationHelper.HasAllowedExtension(f.FileName))
                    .WithMessage($"Invalid photo format. Allowed formats: {string.Join(", ", ImageValidationHelper.AllowedImageExtensions)}.");

                photoRule.Must(f => ImageValidationHelper.HasAllowedContentType(f.ContentType))
                    .WithMessage($"Invalid photo content type. Allowed types: {string.Join(", ", ImageValidationHelper.AllowedImageContentTypes)}.");
            });
    }
}