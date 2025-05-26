using Alpinity.Application.Constants.Search;
using FluentValidation;

namespace Alpinity.Application.UseCases.Users.Commands.GetAllUsers;

public class GetAllUsersCommandValidator : AbstractValidator<GetAllUsersCommand>
{
    public GetAllUsersCommandValidator()
    {
        RuleFor(x => x.Page)
            .GreaterThanOrEqualTo(0)
            .WithMessage("Page must be greater than or equal to 0.");

        RuleFor(x => x.PageSize)
            .GreaterThanOrEqualTo(SearchConsts.MinPageSize)
            .LessThanOrEqualTo(SearchConsts.MaxPageSize)
            .WithMessage($"Page size must be between {SearchConsts.MinPageSize} and {SearchConsts.MaxPageSize}.");

        RuleFor(x => x.Search)
            .MaximumLength(100)
            .When(x => !string.IsNullOrWhiteSpace(x.Search))
            .WithMessage("Search term cannot exceed 100 characters.");
    }
}