using MediatR;
using System;

namespace Alpinity.Application.UseCases.Crags.Commands;

public class DeleteCragCommand : IRequest
{
    public Guid CragId { get; set; }
}