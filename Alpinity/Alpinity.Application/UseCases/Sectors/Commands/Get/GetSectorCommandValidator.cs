using FluentValidation;

namespace Alpinity.Application.UseCases.Sectors.Get;

public class GetSectorCommandValidator : AbstractValidator<GetSectorCommand>
{
    public GetSectorCommandValidator()
    {
        RuleFor(x => x.SectorId)
            .NotEmpty();
    }
}