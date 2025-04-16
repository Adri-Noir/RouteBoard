using Alpinity.Application.Helpers;
using FluentValidation;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.UseCases.Sectors.Commands.Edit;

public class EditSectorCommandValidator : AbstractValidator<EditSectorCommand>
{
    private const int MaxPhotos = 10;

    public EditSectorCommandValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty();

        When(x => x.Name != null, () =>
        {
            RuleFor(x => x.Name)
                .MinimumLength(3).WithMessage("Sector name must be at least 3 characters long.")
                .MaximumLength(100).WithMessage("Sector name cannot exceed 100 characters.");
        });

        When(x => x.Description != null, () =>
        {
            RuleFor(x => x.Description)
                .MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters.");
        });

        // Location validation can be added here if needed
        When(x => x.Location != null, () =>
        {
            RuleFor(x => x.Location)
                .Must(LocationValidationHelper.ValidatePoint)
                .WithMessage("Location coordinates are invalid.");
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