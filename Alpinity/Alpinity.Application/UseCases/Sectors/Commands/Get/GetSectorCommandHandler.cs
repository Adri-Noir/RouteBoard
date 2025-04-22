using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Application.UseCases.Sectors.Dtos;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Sectors.Get;

public class GetSectorCommandHandler(
    IMapper mapper,
    ISectorRepository sectorRepository,
    ISearchHistoryRepository searchHistoryRepository,
    IAuthenticationContext authenticationContext,
    IEntityPermissionService permissionService) : IRequestHandler<GetSectorCommand, SectorDetailedDto>
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
                EntityType = SearchResultItemType.Sector,
                SectorId = sector.Id,
                Sector = sector,
                SearchingUserId = userId.Value,
                SearchedAt = DateTime.UtcNow
            };

            await searchHistoryRepository.AddSearchHistoryAsync(searchHistory, cancellationToken);
        }

        var dto = mapper.Map<SectorDetailedDto>(sector);
        dto.CanModify = await permissionService.CanModifySector(sector.Id, cancellationToken);
        return dto;
    }
}