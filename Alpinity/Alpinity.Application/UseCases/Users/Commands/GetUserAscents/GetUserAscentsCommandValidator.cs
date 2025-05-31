using Alpinity.Application.Constants.Search;
using FluentValidation;

namespace Alpinity.Application.UseCases.Users.Commands.GetUserAscents;

public class GetUserAscentsCommandValidator : AbstractValidator<GetUserAscentsCommand>
{
    public GetUserAscentsCommandValidator()
    {
        RuleFor(x => x.UserId)
            .NotEmpty()
            .WithMessage("User ID is required.");

        RuleFor(x => x.Page)
            .GreaterThanOrEqualTo(0)
            .WithMessage("Page must be greater than or equal to 0.");

        RuleFor(x => x.PageSize)
            .GreaterThanOrEqualTo(SearchConsts.MinPageSize)
            .LessThanOrEqualTo(SearchConsts.MaxPageSize)
            .WithMessage($"Page size must be between {SearchConsts.MinPageSize} and {SearchConsts.MaxPageSize}.");
    }
} 