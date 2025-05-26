using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Application.Constants.Search;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.GetAllUsers;

public class GetAllUsersCommand : IRequest<PaginatedUsersDto>
{
    public int Page { get; set; } = SearchConsts.DefaultPage;
    public int PageSize { get; set; } = SearchConsts.DefaultPageSize;
    public string? Search { get; set; }
}