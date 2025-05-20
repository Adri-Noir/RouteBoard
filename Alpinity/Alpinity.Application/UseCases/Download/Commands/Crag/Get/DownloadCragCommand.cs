using System.Text.Json.Serialization;
using MediatR;
using Alpinity.Application.UseCases.Download.Dtos;

namespace Alpinity.Application.UseCases.Download.Commands.Crag.Get;

public class DownloadCragCommand : IRequest<DownloadCragResponse>
{
    [JsonIgnore]
    public Guid CragId { get; set; }
}


