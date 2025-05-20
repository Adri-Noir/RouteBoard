using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Download.Dtos;
using AutoMapper;
using MediatR;
using ApiExceptions.Exceptions;
using System.Threading;
using System.Threading.Tasks;

namespace Alpinity.Application.UseCases.Download.Commands.Crag.Get;

public class DownloadCragCommandHandler(ICragRepository cragRepository, IMapper mapper) : IRequestHandler<DownloadCragCommand, DownloadCragResponse>
{
    public async Task<DownloadCragResponse> Handle(DownloadCragCommand request, CancellationToken cancellationToken)
    {
        var crag = await cragRepository.GetCragForDownload(request.CragId, cancellationToken) ?? throw new EntityNotFoundException("Crag not found.");
        return mapper.Map<DownloadCragResponse>(crag);
    }
}
