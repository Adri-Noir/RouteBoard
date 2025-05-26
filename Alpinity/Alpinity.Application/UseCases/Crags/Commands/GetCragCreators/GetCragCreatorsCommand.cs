using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.GetCragCreators;

public class GetCragCreatorsCommand : IRequest<ICollection<UserRestrictedDto>>
{
    public Guid CragId { get; set; }
}