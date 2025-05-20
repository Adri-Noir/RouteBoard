using FluentValidation;

namespace Alpinity.Application.UseCases.Download.Commands.Crag.Get;

public class DownloadCragCommandValidator : AbstractValidator<DownloadCragCommand>
{
    public DownloadCragCommandValidator()
    {
        RuleFor(x => x.CragId).NotEmpty().WithMessage("Crag ID is required.");
    }
}
