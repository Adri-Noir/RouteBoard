using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.LogAscent;

public class LogAscentCommandHandler(
    IUserRepository userRepository,
    IRouteRepository routeRepository,
    IAscentRepository ascentRepository) : IRequestHandler<LogAscentCommand>
{
    public async Task Handle(LogAscentCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetByIdAsync(request.UserId);
        if (user is null)
            throw new EntityNotFoundException("User not found");

        var route = await routeRepository.GetRouteById(request.RouteId);
        if (route is null)
            throw new EntityNotFoundException("Route not found");
            
        var ascent = new Ascent
        {
            UserId = request.UserId,
            RouteId = request.RouteId,
            AscentDate = request.AscentDate,
            Notes = request.Notes,
            ClimbTypes = request.ClimbTypes,
            RockTypes = request.RockTypes,
            HoldTypes = request.HoldTypes,
            ProposedGrade = request.ProposedGrade,
            Rating = request.Rating
        };
        
        await ascentRepository.AddAsync(ascent);
        
        return;
    }
} 