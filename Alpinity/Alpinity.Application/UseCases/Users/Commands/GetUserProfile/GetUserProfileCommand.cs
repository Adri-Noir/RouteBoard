using Alpinity.Application.UseCases.Users.Dtos;
using MediatR;

namespace Alpinity.Application.UseCases.Users.Commands.GetUserProfile;

public class GetUserProfileCommand : IRequest<UserProfileDto>
{
    public required Guid ProfileUserId { get; set; }
} 