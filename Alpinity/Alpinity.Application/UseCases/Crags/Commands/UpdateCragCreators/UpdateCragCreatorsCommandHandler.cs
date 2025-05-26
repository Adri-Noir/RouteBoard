using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.UpdateCragCreators;

public class UpdateCragCreatorsCommandHandler(
    ICragRepository cragRepository,
    IUserRepository userRepository,
    IAuthenticationContext authenticationContext) : IRequestHandler<UpdateCragCreatorsCommand>
{
    public async Task Handle(UpdateCragCreatorsCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();

        var cragExists = await cragRepository.CragExists(request.CragId, cancellationToken);
        if (!cragExists)
        {
            throw new EntityNotFoundException("Crag not found.");
        }

        if (userRole != UserRole.Admin && userRole != UserRole.Creator)
        {
            throw new UnAuthorizedAccessException("You are not authorized to manage crag creators. Only users with Creator or Admin role can manage crag users.");
        }

        if (userRole == UserRole.Creator)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await cragRepository.IsUserCreatorOfCrag(request.CragId, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to manage creators for this crag. You must be a creator of this crag.");
            }
        }

        foreach (var userId in request.UserIds)
        {
            var userExists = await userRepository.UserExistsAsync(userId, cancellationToken);
            if (!userExists)
            {
                throw new EntityNotFoundException($"User with ID {userId} not found.");
            }
        }

        var currentCreators = await cragRepository.GetCragCreatorsAsync(request.CragId, cancellationToken);
        var currentCreatorIds = currentCreators.Select(u => u.Id).ToHashSet();

        var usersToAdd = request.UserIds.Where(id => !currentCreatorIds.Contains(id)).ToList();

        var usersToRemove = currentCreatorIds.Where(id => !request.UserIds.Contains(id)).ToList();

        foreach (var userId in usersToAdd)
        {
            await cragRepository.AddCragCreator(request.CragId, userId, cancellationToken);
        }

        foreach (var userId in usersToRemove)
        {
            await cragRepository.RemoveCragCreator(request.CragId, userId, cancellationToken);
        }
    }
}