using Alpinity.Application.Helpers;
using FluentValidation;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.UseCases.Crags.Commands.Edit;

public class EditCragCommandValidator : AbstractValidator<EditCragCommand>
{
    private const int MaxPhotos = 10;

    public EditCragCommandValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty();

        When(x => x.Name != null, () =>
        {
            RuleFor(x => x.Name)
                .MinimumLength(3).WithMessage("Crag name must be at least 3 characters")
                .MaximumLength(100).WithMessage("Crag name cannot exceed 100 characters");
        });

        When(x => x.Description != null, () =>
        {
            RuleFor(x => x.Description)
                .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters");
        });

        When(x => x.Photos != null, () =>
        {
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
        });

        When(x => x.LocationName != null, () =>
        {
            RuleFor(x => x.LocationName)
                .MaximumLength(255).WithMessage("Location name cannot exceed 255 characters");
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