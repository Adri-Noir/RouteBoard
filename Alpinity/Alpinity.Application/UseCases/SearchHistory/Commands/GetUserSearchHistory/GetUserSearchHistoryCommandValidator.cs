using FluentValidation;

namespace Alpinity.Application.UseCases.SearchHistory.Commands.GetUserSearchHistory;

public class GetUserSearchHistoryCommandValidator : AbstractValidator<GetUserSearchHistoryCommand>
{
    public GetUserSearchHistoryCommandValidator()
    {
        RuleFor(x => x.SearchingUserId)
            .NotEmpty()
            .WithMessage("SearchingUserId is required");

        RuleFor(x => x.Count)
            .GreaterThan(0)
            .WithMessage("Count must be greater than 0")
            .LessThanOrEqualTo(100)
            .WithMessage("Count must be less than or equal to 100");
    }
}
