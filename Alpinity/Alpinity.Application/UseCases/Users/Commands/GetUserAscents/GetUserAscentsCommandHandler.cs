using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Users.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.GetUserAscents;

public class GetUserAscentsCommandHandler(
    IAscentRepository ascentRepository,
    IUserRepository userRepository,
    IMapper mapper) : IRequestHandler<GetUserAscentsCommand, PaginatedUserAscentsDto>
{
    public async Task<PaginatedUserAscentsDto> Handle(GetUserAscentsCommand request, CancellationToken cancellationToken)
    {
        // Check if user exists
        var userExists = await userRepository.UserExistsAsync(request.UserId, cancellationToken);
        if (!userExists)
        {
            throw new EntityNotFoundException("User not found");
        }

        // Get paginated ascents
        var (ascents, totalCount) = await ascentRepository.GetPaginatedByUserIdAsync(
            request.UserId, 
            request.Page, 
            request.PageSize, 
            cancellationToken);

        return new PaginatedUserAscentsDto
        {
            Ascents = mapper.Map<ICollection<UserAscentDto>>(ascents),
            TotalCount = totalCount
        };
    }
} 