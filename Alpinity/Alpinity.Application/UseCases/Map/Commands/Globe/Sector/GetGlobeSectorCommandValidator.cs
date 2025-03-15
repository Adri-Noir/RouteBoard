using FluentValidation;

namespace Alpinity.Application.UseCases.Map.Commands.Globe.Sector;

public class GetGlobeSectorCommandValidator : AbstractValidator<GetGlobeSectorCommand>
{
    public GetGlobeSectorCommandValidator()
    {
        RuleFor(x => x.CragId).NotEmpty().WithMessage("CragId is required");
    }
}
