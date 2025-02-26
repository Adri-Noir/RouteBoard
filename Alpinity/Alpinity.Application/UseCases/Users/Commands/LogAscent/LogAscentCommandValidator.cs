using FluentValidation;
using Alpinity.Domain.Enums;
using System;
using System.Linq;

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
            .InclusiveBetween(1, 5)
            .When(x => x.Rating.HasValue)
            .WithMessage("Rating must be between 1 and 5");
            
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
    }
} 