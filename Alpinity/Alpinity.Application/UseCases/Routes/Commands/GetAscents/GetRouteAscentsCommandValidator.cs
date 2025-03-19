using System;
using FluentValidation;

namespace Alpinity.Application.UseCases.Routes.Commands.GetAscents;

public class GetRouteAscentsCommandValidator : AbstractValidator<GetRouteAscentsCommand>
{
    public GetRouteAscentsCommandValidator()
    {
        RuleFor(x => x.Id).NotEmpty().WithMessage("Id is required");
    }
}
