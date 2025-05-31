namespace Alpinity.Application.UseCases.Users.Dtos;

public class PaginatedUserAscentsDto
{
    public ICollection<UserAscentDto> Ascents { get; set; } = new List<UserAscentDto>();
    public int TotalCount { get; set; }
} 