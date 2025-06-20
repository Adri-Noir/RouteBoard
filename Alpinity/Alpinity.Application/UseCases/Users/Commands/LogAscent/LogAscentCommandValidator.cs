using FluentValidation;
using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Users.Commands.LogAscent;

public class LogAscentCommandValidator : AbstractValidator<LogAscentCommand>
{
    public LogAscentCommandValidator()
    {
        RuleFor(x => x.RouteId)
            .NotEmpty().WithMessage("Route ID is required");

        RuleFor(x => x.AscentDate)
            .NotEmpty().WithMessage("Ascent date is required")
            .LessThanOrEqualTo(DateTime.UtcNow).WithMessage("Ascent date cannot be in the future");

        RuleFor(x => x.Rating)
            .InclusiveBetween(0, 5)
            .When(x => x.Rating.HasValue)
            .WithMessage("Rating must be between 0 and 5");

        RuleFor(x => x.Notes)
            .MaximumLength(2000)
            .When(x => !string.IsNullOrEmpty(x.Notes))
            .WithMessage("Notes cannot exceed 2000 characters");

        RuleFor(x => x.ClimbTypes)
            .Must(types => types == null || types.All(t => Enum.IsDefined(typeof(ClimbType), t)))
            .When(x => x.ClimbTypes != null && x.ClimbTypes.Any())
            .WithMessage("One or more ClimbTypes are invalid");

        RuleFor(x => x.RockTypes)
            .Must(types => types == null || types.All(t => Enum.IsDefined(typeof(RockType), t)))
            .When(x => x.RockTypes != null && x.RockTypes.Any())
            .WithMessage("One or more RockTypes are invalid");

        RuleFor(x => x.HoldTypes)
            .Must(types => types == null || types.All(t => Enum.IsDefined(typeof(HoldType), t)))
            .When(x => x.HoldTypes != null && x.HoldTypes.Any())
            .WithMessage("One or more HoldTypes are invalid");

        RuleFor(x => x.ProposedGrade)
            .Must(grade => grade == null || Enum.IsDefined(typeof(ClimbingGrade), grade))
            .When(x => x.ProposedGrade.HasValue)
            .WithMessage("The proposed climbing grade is invalid");

        RuleFor(x => x.AscentType)
            .NotEmpty().WithMessage("Ascent type is required")
            .Must(type => Enum.IsDefined(typeof(AscentType), type))
            .WithMessage("The ascent type is invalid");

        RuleFor(x => x.NumberOfAttempts)
            .GreaterThan(1)
            .When(x => x.AscentType == AscentType.Redpoint || x.AscentType == AscentType.Aid)
            .WithMessage("Number of attempts must be greater than 1 for Redpoint or Aid ascent types");

        RuleFor(x => x.NumberOfAttempts)
            .GreaterThan(0)
            .When(x => x.NumberOfAttempts.HasValue)
            .WithMessage("Number of attempts must be greater than 0");
    }
}