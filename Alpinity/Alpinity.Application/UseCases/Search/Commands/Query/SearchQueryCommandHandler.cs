using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Search.Dtos;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Search.Commands.Query;

public class SearchQueryCommandHandler(
    ICragRepository cragRepository,
    ISectorRepository sectorRepository,
    IRouteRepository routeRepository,
    IUserRepository userRepository,
    IMapper mapper) : IRequestHandler<SearchQueryCommand, ICollection<SearchResultDto>>
{
    public async Task<ICollection<SearchResultDto>> Handle(SearchQueryCommand request, CancellationToken cancellationToken)
    {
        var searchOptions = new SearchOptionsDto
        {
            Page = request.page,
            PageSize = request.pageSize
        };
        var routes = await routeRepository.GetRoutesByName(request.query, searchOptions, cancellationToken);
        var sectors = await sectorRepository.GetSectorsByName(request.query, searchOptions, cancellationToken);
        var crags = await cragRepository.GetCragsByName(request.query, searchOptions, cancellationToken);
        var users = await userRepository.GetUsersByUsernameAsync(request.query, searchOptions, cancellationToken);

        var items = new List<SearchResultDto>();
        items.AddRange(routes.Select(route => mapper.Map<SearchResultDto>(route)));
        items.AddRange(sectors.Select(sector => mapper.Map<SearchResultDto>(sector)));
        items.AddRange(crags.Select(crag => mapper.Map<SearchResultDto>(crag)));
        items.AddRange(users.Select(user => mapper.Map<SearchResultDto>(user)));

        return items;
    }
}