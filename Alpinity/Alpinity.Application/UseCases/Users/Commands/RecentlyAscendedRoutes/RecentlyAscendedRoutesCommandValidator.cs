using System;
using FluentValidation;

namespace Alpinity.Application.UseCases.Users.Commands.RecentlyAscendedRoutes;

public class RecentlyAscendedRoutesCommandValidator : AbstractValidator<RecentlyAscendedRoutesCommand>
{
    public RecentlyAscendedRoutesCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty().WithMessage("User ID is required");
    }
}
