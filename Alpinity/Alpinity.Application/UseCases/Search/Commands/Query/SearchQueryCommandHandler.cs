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

        var routesTask = routeRepository.GetRoutesByName(request.query, searchOptions, cancellationToken);
        var sectorsTask = sectorRepository.GetSectorsByName(request.query, searchOptions, cancellationToken);
        var cragsTask = cragRepository.GetCragsByName(request.query, searchOptions, cancellationToken);
        var usersTask = userRepository.GetUsersByUsernameAsync(request.query, searchOptions, cancellationToken);

        await Task.WhenAll(routesTask, sectorsTask, cragsTask, usersTask);

        var routes = routesTask.Result;
        var sectors = sectorsTask.Result;
        var crags = cragsTask.Result;
        var users = usersTask.Result;

        var items = new List<SearchResultDto>();
        items.AddRange(routes.Select(route => mapper.Map<SearchResultDto>(route)));
        items.AddRange(sectors.Select(sector => mapper.Map<SearchResultDto>(sector)));
        items.AddRange(crags.Select(crag => mapper.Map<SearchResultDto>(crag)));
        items.AddRange(users.Select(user => mapper.Map<SearchResultDto>(user)));

        return items;
    }
}