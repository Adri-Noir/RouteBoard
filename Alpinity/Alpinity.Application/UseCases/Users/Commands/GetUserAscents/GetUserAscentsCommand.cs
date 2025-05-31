using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Application.Constants.Search;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.GetUserAscents;

public class GetUserAscentsCommand : IRequest<PaginatedUserAscentsDto>
{
    public Guid UserId { get; set; }
    public int Page { get; set; } = SearchConsts.DefaultPage;
    public int PageSize { get; set; } = SearchConsts.DefaultPageSize;
} 