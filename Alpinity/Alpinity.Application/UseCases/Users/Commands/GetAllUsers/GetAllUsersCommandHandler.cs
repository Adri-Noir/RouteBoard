using Alpinity.Application.Dtos;
using Alpinity.Application.Interfaces;
using Alpinity.Application.Interfaces.Repositories;
using Alpinity.Application.UseCases.Users.Dtos;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using ApiExceptions.Exceptions;
using AutoMapper;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.GetAllUsers;

public class GetAllUsersCommandHandler(
    IUserRepository userRepository,
    IAuthenticationContext authenticationContext,
    IMapper mapper) : IRequestHandler<GetAllUsersCommand, PaginatedUsersDto>
{
    public async Task<PaginatedUsersDto> Handle(GetAllUsersCommand request, CancellationToken cancellationToken)
    {
        var userRole = authenticationContext.GetUserRole();

        // Check authorization - only admins and users with Creator role can view all users
        if (userRole != UserRole.Admin && userRole != UserRole.Creator)
        {
            throw new UnAuthorizedAccessException("You are not authorized to view all users. Only users with Creator or Admin role can access this data.");
        }

        // Get users with pagination and optional search
        var searchOptions = new SearchOptionsDto
        {
            Query = request.Search ?? string.Empty,
            Page = request.Page,
            PageSize = request.PageSize
        };

        var (users, totalCount) = await userRepository.GetAllUsersWithCountAsync(searchOptions, cancellationToken);

        return new PaginatedUsersDto
        {
            Users = mapper.Map<ICollection<UserRestrictedDto>>(users),
            TotalCount = totalCount
        };
    }
}