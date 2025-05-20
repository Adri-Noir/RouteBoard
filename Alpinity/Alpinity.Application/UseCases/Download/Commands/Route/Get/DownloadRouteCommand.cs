namespace Alpinity.Application.UseCases.Download.Commands.Route.Get;

using MediatR;
using Alpinity.Application.UseCases.Download.Dtos;

public class DownloadRouteCommand : IRequest<DownloadRouteResponse>
{
    public required Guid Id { get; set; }
}
