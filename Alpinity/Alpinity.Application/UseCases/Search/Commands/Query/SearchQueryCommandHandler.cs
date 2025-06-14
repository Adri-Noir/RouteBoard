using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Search.Dtos;
using AutoMapper;
using MediatR;
using Microsoft.Extensions.DependencyInjection;

namespace Alpinity.Application.UseCases.Search.Commands.Query;

public class SearchQueryCommandHandler(IServiceScopeFactory scopeFactory, IMapper mapper) : IRequestHandler<SearchQueryCommand, ICollection<SearchResultDto>>
{
    public async Task<ICollection<SearchResultDto>> Handle(SearchQueryCommand request, CancellationToken cancellationToken)
    {
        var searchOptions = new SearchOptionsDto
        {
            Page = request.page,
            PageSize = request.pageSize
        };

        var routesTask = Task.Run(async () =>
        {
            using var scope = scopeFactory.CreateScope();
            var repo = scope.ServiceProvider.GetRequiredService<IRouteRepository>();
            return await repo.GetRoutesByName(request.query, searchOptions, cancellationToken);
        }, cancellationToken);

        var sectorsTask = Task.Run(async () =>
        {
            using var scope = scopeFactory.CreateScope();
            var repo = scope.ServiceProvider.GetRequiredService<ISectorRepository>();
            return await repo.GetSectorsByName(request.query, searchOptions, cancellationToken);
        }, cancellationToken);

        var cragsTask = Task.Run(async () =>
        {
            using var scope = scopeFactory.CreateScope();
            var repo = scope.ServiceProvider.GetRequiredService<ICragRepository>();
            return await repo.GetCragsByName(request.query, searchOptions, cancellationToken);
        }, cancellationToken);

        var usersTask = Task.Run(async () =>
        {
            using var scope = scopeFactory.CreateScope();
            var repo = scope.ServiceProvider.GetRequiredService<IUserRepository>();
            return await repo.GetUsersByUsernameAsync(request.query, searchOptions, cancellationToken);
        }, cancellationToken);

        await Task.WhenAll(routesTask, sectorsTask, cragsTask, usersTask);

        var items = new List<SearchResultDto>();
        items.AddRange(routesTask.Result.Select(mapper.Map<SearchResultDto>));
        items.AddRange(sectorsTask.Result.Select(mapper.Map<SearchResultDto>));
        items.AddRange(cragsTask.Result.Select(mapper.Map<SearchResultDto>));
        items.AddRange(usersTask.Result.Select(mapper.Map<SearchResultDto>));

        return items;
    }
}