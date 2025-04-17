using FluentValidation;

namespace Alpinity.Application.UseCases.Sectors.Commands;

public class DeleteSectorCommandValidator : AbstractValidator<DeleteSectorCommand>
{
    public DeleteSectorCommandValidator()
    {
        RuleFor(x => x.SectorId)
            .NotEmpty().WithMessage("Sector ID is required");
    }
}