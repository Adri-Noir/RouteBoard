using System.Text.Json.Serialization;
using Alpinity.Application.UseCases.SearchHistory.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.SearchHistory.Commands.GetUserSearchHistory;

public class GetUserSearchHistoryCommand : IRequest<ICollection<SearchHistoryDto>>
{
    [JsonIgnore]
    public Guid SearchingUserId { get; set; }
    
    public int Count { get; set; } = 10;
} 