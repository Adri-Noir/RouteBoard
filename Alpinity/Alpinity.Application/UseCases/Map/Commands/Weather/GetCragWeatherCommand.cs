using System;
using Alpinity.Application.UseCases.Map.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Map.Commands.Weather;

public class GetCragWeatherCommand : IRequest<WeatherResponseDto>
{
    public Guid CragId { get; set; }
}
