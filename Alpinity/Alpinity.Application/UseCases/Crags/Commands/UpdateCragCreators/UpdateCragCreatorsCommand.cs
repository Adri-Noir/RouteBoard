using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.UpdateCragCreators;

public class UpdateCragCreatorsCommand : IRequest
{
    public Guid CragId { get; set; }
    public ICollection<Guid> UserIds { get; set; } = new List<Guid>();
}