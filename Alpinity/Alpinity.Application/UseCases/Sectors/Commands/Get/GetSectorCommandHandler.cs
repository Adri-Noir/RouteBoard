using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Entities;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Get;

public class GetSectorCommandHandler(
    IMapper mapper,
    ISectorRepository sectorRepository,
    ISearchHistoryRepository searchHistoryRepository,
    IAuthenticationContext authenticationContext) : IRequestHandler<GetSectorCommand, SectorDetailedDto>
{
    public async Task<SectorDetailedDto> Handle(GetSectorCommand request, CancellationToken cancellationToken)
    {
        var sector = await sectorRepository.GetSectorById(request.SectorId, cancellationToken);

        if (sector == null)
        {
            throw new EntityNotFoundException("Sector not found.");
        }

        // Save search history if user is authenticated
        var userId = authenticationContext.GetUserId();
        if (userId.HasValue)
        {
            var searchHistory = new Domain.Entities.SearchHistory
            {
                Id = Guid.NewGuid(),
                SectorId = sector.Id,
                Sector = sector,
                SearchingUserId = userId.Value,
                SearchedAt = DateTime.UtcNow
            };

            await searchHistoryRepository.AddSearchHistoryAsync(searchHistory, cancellationToken);
        }

        return mapper.Map<SectorDetailedDto>(sector);
    }
}