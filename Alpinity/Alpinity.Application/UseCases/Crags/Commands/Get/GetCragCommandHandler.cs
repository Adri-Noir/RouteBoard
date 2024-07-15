using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Crags.Dtos;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Crags.Commands.Get;

public class GetCragCommandHandler(ICragRepository cragRepository, IMapper mapper) : IRequestHandler<GetCragCommand, CragDetailedDto>
{

    public async Task<CragDetailedDto> Handle(GetCragCommand request, CancellationToken cancellationToken)
    {
        var crag = await cragRepository.GetCragById(request.Id);

        if (crag == null)
        {
            throw new EntityNotFoundException("Crag not found.");
        }

        return mapper.Map<CragDetailedDto>(crag);
    }
}