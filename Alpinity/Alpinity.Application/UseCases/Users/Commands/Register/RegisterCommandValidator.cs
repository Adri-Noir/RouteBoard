using FluentValidation;

namespace Alpinity.Application.UseCases.Users.Commands.Register;

public class RegisterCommandValidator : AbstractValidator<RegisterCommand>
{
    public RegisterCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required")
            .EmailAddress().WithMessage("Email is not valid");

        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Username is required")
            .MinimumLength(3).WithMessage("Username must be at least 3 characters")
            .MaximumLength(256).WithMessage("Username must not exceed 256 characters");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required")
            .MinimumLength(8).WithMessage("Password must be at least 8 characters")
            .MaximumLength(64).WithMessage("Password must not exceed 64 characters");

        RuleFor(x => x.FirstName)
            .MaximumLength(256).WithMessage("First name must not exceed 256 characters");

        RuleFor(x => x.LastName)
            .MaximumLength(256).WithMessage("Last name must not exceed 256 characters");
    }
}