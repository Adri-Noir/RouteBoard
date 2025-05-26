namespace Alpinity.Application.UseCases.Users.Dtos;

public class PaginatedUsersDto
{
    public ICollection<UserRestrictedDto> Users { get; set; } = new List<UserRestrictedDto>();
    public int TotalCount { get; set; }
}