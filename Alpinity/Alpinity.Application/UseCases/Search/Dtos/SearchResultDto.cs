

namespace Alpinity.Application.UseCases.Search.Dtos;


public class SearchResultDto
{
    public ICollection<SearchResultItemDto> Items { get; set; } = null!;
}