using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Users.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.GetUserProfile;

public class GetUserProfileCommandHandler(
    IUserRepository userRepository,
    ISearchHistoryRepository searchHistoryRepository,
    IAuthenticationContext authenticationContext,
    IMapper mapper) : IRequestHandler<GetUserProfileCommand, UserProfileDto>
{
    public async Task<UserProfileDto> Handle(GetUserProfileCommand request, CancellationToken cancellationToken)
    {
        var profileUser = await userRepository.GetByIdAsync(request.ProfileUserId);

        if (profileUser == null) throw new EntityNotFoundException("User not found.");

        // Save search history if user is authenticated
        var searchingUserId = authenticationContext.GetUserId();
        if (searchingUserId.HasValue)
        {
            var searchHistory = new Domain.Entities.SearchHistory
            {
                Id = Guid.NewGuid(),
                ProfileUserId = profileUser.Id,
                ProfileUser = profileUser,
                SearchingUserId = searchingUserId.Value,
                SearchedAt = DateTime.UtcNow
            };

            await searchHistoryRepository.AddSearchHistoryAsync(searchHistory);
        }

        return mapper.Map<UserProfileDto>(profileUser);
    }
}