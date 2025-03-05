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
        var profileUser = await userRepository.GetUserProfileAsync(request.ProfileUserId) ?? throw new EntityNotFoundException("User not found.");
        
        var searchingUserId = authenticationContext.GetUserId();
        if (searchingUserId.HasValue && searchingUserId.Value != request.ProfileUserId)
        {
            var searchHistory = new Domain.Entities.SearchHistory
            {
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