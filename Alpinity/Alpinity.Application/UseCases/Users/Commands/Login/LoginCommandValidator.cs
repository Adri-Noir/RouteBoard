using FluentValidation;

namespace Alpinity.Application.UseCases.Users.Commands.Login;

public class LoginCommandValidator : AbstractValidator<LoginCommand>
{
    public LoginCommandValidator()
    {
        RuleFor(x => x.NormalizedUsernameOrEmail)
            .NotEmpty();
        RuleFor(x => x.Password)
            .NotEmpty();
    }
}