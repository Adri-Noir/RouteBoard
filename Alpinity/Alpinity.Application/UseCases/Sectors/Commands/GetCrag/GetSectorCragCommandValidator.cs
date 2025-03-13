using FluentValidation;

namespace Alpinity.Application.UseCases.Sectors.Commands.GetCrag;

public class GetSectorCragCommandValidator : AbstractValidator<GetSectorCragCommand>
{
    public GetSectorCragCommandValidator()
    {
        RuleFor(x => x.SectorId)
            .NotEmpty()
            .WithMessage("Sector ID is required");
    }
}
