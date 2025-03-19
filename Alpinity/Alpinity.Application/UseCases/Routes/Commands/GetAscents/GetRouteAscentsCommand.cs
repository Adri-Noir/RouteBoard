using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;
namespace Alpinity.Application.UseCases.Routes.Commands.GetAscents;

public class GetRouteAscentsCommand : IRequest<ICollection<AscentDto>>
{
    public Guid Id { get; set; }
}
