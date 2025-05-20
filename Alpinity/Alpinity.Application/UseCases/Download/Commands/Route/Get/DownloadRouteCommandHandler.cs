using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Download.Dtos;
using AutoMapper;
using MediatR;
using ApiExceptions.Exceptions;
using System.Threading;
using System.Threading.Tasks;

namespace Alpinity.Application.UseCases.Download.Commands.Route.Get;

public class DownloadRouteCommandHandler(IRouteRepository routeRepository, IMapper mapper) : IRequestHandler<DownloadRouteCommand, DownloadRouteResponse>
{
    public async Task<DownloadRouteResponse> Handle(DownloadRouteCommand request, CancellationToken cancellationToken)
    {
        var route = await routeRepository.GetRouteForDownload(request.Id, cancellationToken) ?? throw new EntityNotFoundException("Route not found.");
        return mapper.Map<DownloadRouteResponse>(route);
    }
}