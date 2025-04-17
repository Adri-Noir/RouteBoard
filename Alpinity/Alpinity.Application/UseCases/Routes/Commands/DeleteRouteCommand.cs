using MediatR;
using System;

namespace Alpinity.Application.UseCases.Routes.Commands;

public class DeleteRouteCommand : IRequest
{
    public Guid RouteId { get; set; }
}