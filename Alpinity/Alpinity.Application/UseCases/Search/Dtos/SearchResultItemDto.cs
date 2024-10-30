using Alpinity.Domain.Enums;

namespace Alpinity.Application.UseCases.Search.Dtos;

public class SearchResultItemDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
    public string Description { get; set; } = null!;
    public SearchResultItemType Type { get; set; }
}