using FluentValidation;

namespace Alpinity.Application.UseCases.Download.Commands.Route.Get;

public class DownloadRouteCommandValidator : AbstractValidator<DownloadRouteCommand>
{
    public DownloadRouteCommandValidator()
    {
        RuleFor(x => x.Id).NotEmpty().WithMessage("Route ID is required");
    }
}