using Alpinity.Application.Constants.Search;
using FluentValidation;

namespace Alpinity.Application.UseCases.Search.Commands.Query;

public class SearchQueryCommandValidator : AbstractValidator<SearchQueryCommand>
{
    public SearchQueryCommandValidator()
    {
        RuleFor(x => x.query)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100);
        RuleFor(x => x.page)
            .GreaterThanOrEqualTo(0);
        RuleFor(x => x.pageSize)
            .GreaterThanOrEqualTo(SearchConsts.MinPageSize)
            .LessThanOrEqualTo(SearchConsts.MaxPageSize);
    }
}