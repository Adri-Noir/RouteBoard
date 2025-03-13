using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.Search.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.SearchHistory.Commands.GetUserSearchHistory;

public class GetUserSearchHistoryCommand : IRequest<ICollection<SearchResultDto>>
{
    [JsonIgnore]
    public Guid SearchingUserId { get; set; }
    
    public int Count { get; set; } = 10;
} 