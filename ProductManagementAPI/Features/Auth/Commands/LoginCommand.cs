using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Features.Auth.Commands
{
    public class LoginCommand : IRequest<ApiResponse<AuthResponseDto>>
    {
        public LoginDto LoginDto { get; set; } = null!;
    }
}