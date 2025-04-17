using MediatR;
using System;

namespace Alpinity.Application.UseCases.Sectors.Commands;

public class DeleteSectorCommand : IRequest
{
    public Guid SectorId { get; set; }
}