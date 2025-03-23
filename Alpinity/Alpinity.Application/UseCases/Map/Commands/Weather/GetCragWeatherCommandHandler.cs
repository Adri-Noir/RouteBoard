using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Application.UseCases.Map.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Map.Commands.Weather;

public class GetCragWeatherCommandHandler(
    ICragRepository cragRepository,
    IWeatherService weatherService,
    ICragWeatherRepository cragWeatherRepository,
    IMapper mapper) : IRequestHandler<GetCragWeatherCommand, WeatherResponseDto>
{
    public async Task<WeatherResponseDto> Handle(GetCragWeatherCommand request, CancellationToken cancellationToken)
    {
        var location = await cragRepository.GetCragLocation(request.CragId, cancellationToken) ?? throw new EntityNotFoundException("Crag location not found");

        var cachedWeather = await cragWeatherRepository.GetLatestWeatherForCragAsync(request.CragId, cancellationToken);

        if (cachedWeather != null && !cachedWeather.IsExpired())
        {
            return mapper.Map<WeatherResponseDto>(cachedWeather.GetWeatherInformation());
        }

        var weather = await weatherService.GetWeatherInformationAsync(location.Y, location.X);
        await cragWeatherRepository.SaveWeatherForCragAsync(request.CragId, weather, cancellationToken);

        return mapper.Map<WeatherResponseDto>(weather);
    }
}
