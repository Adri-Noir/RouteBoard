using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Search.Dtos;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.SearchHistory.Commands.GetUserSearchHistory;

public class GetUserSearchHistoryCommandHandler(
    ISearchHistoryRepository searchHistoryRepository,
    IMapper mapper) : IRequestHandler<GetUserSearchHistoryCommand, ICollection<SearchResultDto>>
{
    public async Task<ICollection<SearchResultDto>> Handle(GetUserSearchHistoryCommand request, CancellationToken cancellationToken)
    {
        var searchHistories = await searchHistoryRepository.GetRecentSearchesByUserAsync(request.SearchingUserId, request.Count, cancellationToken);

        return mapper.Map<ICollection<SearchResultDto>>(searchHistories);
    }
}