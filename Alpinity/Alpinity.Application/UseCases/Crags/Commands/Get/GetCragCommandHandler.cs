using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.Get;

public class GetCragCommandHandler(
    ICragRepository cragRepository,
    ISearchHistoryRepository searchHistoryRepository,
    IAuthenticationContext authenticationContext,
    IMapper mapper) : IRequestHandler<GetCragCommand, CragDetailedDto>
{
    public async Task<CragDetailedDto> Handle(GetCragCommand request, CancellationToken cancellationToken)
    {
        var crag = await cragRepository.GetCragById(request.CragId, cancellationToken) ?? throw new EntityNotFoundException("Crag not found.");

        var userId = authenticationContext.GetUserId();
        if (userId.HasValue)
        {
            var searchHistory = new Domain.Entities.SearchHistory
            {
                Id = Guid.NewGuid(),
                EntityType = SearchResultItemType.Crag,
                CragId = crag.Id,
                Crag = crag,
                SearchingUserId = userId.Value,
                SearchedAt = DateTime.UtcNow
            };

            await searchHistoryRepository.AddSearchHistoryAsync(searchHistory, cancellationToken);
        }

        return mapper.Map<CragDetailedDto>(crag);
    }
}