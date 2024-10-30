using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Search.Dtos;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Search.Get;

public class GetSearchCommandHandler(ICragRepository cragRepository, ISectorRepository sectorRepository, IRouteRepository routeRepository, IMapper mapper) : IRequestHandler<GetSearchCommand, SearchResultDto>
{
    public async Task<SearchResultDto> Handle(GetSearchCommand request, CancellationToken cancellationToken)
    {
        var searchOptions = new SearchOptionsDto
        {
            Page = request.page,
            PageSize = request.pageSize
        };
        var routes = await routeRepository.GetRoutesByName(request.query, searchOptions);
        var sectors = await sectorRepository.GetSectorsByName(request.query, searchOptions);
        var crags = await cragRepository.GetCragsByName(request.query, searchOptions);
        
        var items = new List<SearchResultItemDto>();
        items.AddRange(routes.Select(route => mapper.Map<SearchResultItemDto>(route)));
        items.AddRange(sectors.Select(sector => mapper.Map<SearchResultItemDto>(sector)));
        items.AddRange(crags.Select(crag => mapper.Map<SearchResultItemDto>(crag)));
        
        return new SearchResultDto
        {
            Items = items
        };
    }
}