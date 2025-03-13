using Alpinity.Application.UseCases.Search.Dtos;
using Alpinity.Application.Constants.Search;
using MediatR;

namespace Alpinity.Application.UseCases.Search.Commands.Query;

public class SearchQueryCommand : IRequest<ICollection<SearchResultDto>>
{
    // TODO: implement location based on user's location
    public required string query { get; set; }
    public int page { get; set; } = SearchConsts.DefaultPage;
    public int pageSize { get; set; } = SearchConsts.DefaultPageSize;
}