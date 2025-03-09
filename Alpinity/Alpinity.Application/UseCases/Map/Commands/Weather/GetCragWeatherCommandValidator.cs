using System;
using FluentValidation;

namespace Alpinity.Application.UseCases.Map.Commands.Weather;

public class GetCragWeatherCommandValidator : AbstractValidator<GetCragWeatherCommand>
{
    public GetCragWeatherCommandValidator()
    {
        RuleFor(x => x.CragId).NotEmpty().WithMessage("Crag ID is required");
    }
}
