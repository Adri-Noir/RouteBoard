using System;
using FluentValidation;

namespace Alpinity.Application.UseCases.Users.Commands.Me;

public class MeCommandValidator : AbstractValidator<MeCommand>
{
    public MeCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty().WithMessage("User ID is required");
        RuleFor(x => x.Token).NotEmpty().WithMessage("Token is required");
    }
}
