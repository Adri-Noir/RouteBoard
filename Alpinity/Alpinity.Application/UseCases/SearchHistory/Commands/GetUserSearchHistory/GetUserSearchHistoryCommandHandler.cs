using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.SearchHistory.Dtos;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.SearchHistory.Commands.GetUserSearchHistory;

public class GetUserSearchHistoryCommandHandler(
    ISearchHistoryRepository searchHistoryRepository,
    IMapper mapper) : IRequestHandler<GetUserSearchHistoryCommand, ICollection<SearchHistoryDto>>
{
    public async Task<ICollection<SearchHistoryDto>> Handle(GetUserSearchHistoryCommand request, CancellationToken cancellationToken)
    {
        // Get the search history items with all related data included
        var searchHistories = await searchHistoryRepository.GetRecentSearchesByUserAsync(request.SearchingUserId, request.Count);
        
        // The repository already includes all the necessary related data through eager loading
        // No additional data fetching is needed here as it's handled by the repository
        
        // Map the entities to DTOs, which will include all the related data
        return mapper.Map<ICollection<SearchHistoryDto>>(searchHistories);
    }
} 