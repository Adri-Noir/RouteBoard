using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.GetCragCreators;

public class GetCragCreatorsCommandHandler(
    ICragRepository cragRepository,
    IAuthenticationContext authenticationContext,
    IMapper mapper) : IRequestHandler<GetCragCreatorsCommand, ICollection<UserRestrictedDto>>
{
    public async Task<ICollection<UserRestrictedDto>> Handle(GetCragCreatorsCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();

        var cragExists = await cragRepository.CragExists(request.CragId, cancellationToken);
        if (!cragExists)
        {
            throw new EntityNotFoundException("Crag not found.");
        }

        if (userRole != UserRole.Admin && userRole != UserRole.Creator)
        {
            throw new UnAuthorizedAccessException("You are not authorized to view crag creators. Only users with Creator or Admin role can access this data.");
        }

        if (userRole == UserRole.Creator)
        {
            var userId = authenticationContext.GetUserId() ?? throw new UnAuthorizedAccessException("Invalid User ID");
            if (!await cragRepository.IsUserCreatorOfCrag(request.CragId, userId, cancellationToken))
            {
                throw new UnAuthorizedAccessException("You are not authorized to view creators for this crag. You must be a creator of this crag.");
            }
        }

        var cragCreators = await cragRepository.GetCragCreatorsAsync(request.CragId, cancellationToken);

        return mapper.Map<ICollection<UserRestrictedDto>>(cragCreators);
    }
}