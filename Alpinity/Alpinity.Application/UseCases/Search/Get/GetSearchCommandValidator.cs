using Alpinity.Application.UseCases.Sectors.Create;
using Alpinity.Domain.Constants.Search;
using FluentValidation;

namespace Alpinity.Application.UseCases.Search.Get;

public class GetSearchCommandValidator : AbstractValidator<GetSearchCommand>
{
    public GetSearchCommandValidator()
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