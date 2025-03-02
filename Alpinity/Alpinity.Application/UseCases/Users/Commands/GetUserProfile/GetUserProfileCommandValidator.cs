using FluentValidation;

namespace Alpinity.Application.UseCases.Users.Commands.GetUserProfile;

public class GetUserProfileCommandValidator : AbstractValidator<GetUserProfileCommand>
{
    public GetUserProfileCommandValidator()
    {
        RuleFor(x => x.ProfileUserId)
            .NotEmpty()
            .WithMessage("ProfileUserId is required");
    }
}