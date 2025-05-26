namespace Alpinity.Application.UseCases.Crags.Dtos;

public class UpdateCragCreatorsDto
{
    public ICollection<Guid> UserIds { get; set; } = new List<Guid>();
}