using Alpinity.Application.UseCases.Search.Dtos;
using Alpinity.Domain.Constants.Search;
using MediatR;

namespace Alpinity.Application.UseCases.Search.Get;

public class GetSearchCommand : IRequest<SearchResultDto>
{
    // TODO: implement location based on user's location
    public required string query { get; set; }
    public int page { get; set; } = SearchConsts.DefaultPage;
    public int pageSize { get; set; } = SearchConsts.DefaultPageSize;
}