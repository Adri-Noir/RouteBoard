using Alpinity.Application.Constants.Search;

namespace Alpinity.Application.Dtos;

public class SearchOptionsDto
{
    public string Query { get; set; }
    public int Page { get; set; } = SearchConsts.DefaultPage;
    public int PageSize { get; set; } = SearchConsts.DefaultPageSize;
}