using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Features.Auth.Commands
{
    public class RegisterCommand : IRequest<ApiResponse<UserDto>>
    {
        public RegisterDto RegisterDto { get; set; } = null!;
    }
}