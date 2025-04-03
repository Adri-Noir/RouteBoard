using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.Interfaces.Services;
using Alpinity.Application.UseCases.Crags.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.Create;

public class CreateCragCommandHandler(ICragRepository repository, IMapper mapper, IAuthenticationContext authenticationContext) : IRequestHandler<CreateCragCommand, CragDetailedDto>
{
    public async Task<CragDetailedDto> Handle(CreateCragCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();

        if (userRole != UserRole.Admin && userRole != UserRole.Creator)
        {
            throw new UnAuthorizedAccessException("You are not authorized to create a crag.");
        }

        var crag = new Crag
        {
            Name = request.Name,
            Description = request.Description,
        };

        await repository.CreateCrag(crag, cancellationToken);

        return mapper.Map<CragDetailedDto>(crag);
    }
}