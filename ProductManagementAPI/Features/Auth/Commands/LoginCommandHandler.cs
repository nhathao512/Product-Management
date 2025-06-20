using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;
using ProductManagementAPI.Services;

namespace ProductManagementAPI.Features.Auth.Commands
{
    public class LoginCommandHandler : IRequestHandler<LoginCommand, ApiResponse<AuthResponseDto>>
    {
        private readonly IAuthService _authService;
        private readonly ILogger<LoginCommandHandler> _logger;

        public LoginCommandHandler(IAuthService authService, ILogger<LoginCommandHandler> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        public async Task<ApiResponse<AuthResponseDto>> Handle(LoginCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var authResponse = await _authService.LoginAsync(request.LoginDto);
                if (authResponse != null)
                {
                    return new ApiResponse<AuthResponseDto>
                    {
                        Success = true,
                        Data = authResponse,
                        Message = "Login successful"
                    };
                }

                return new ApiResponse<AuthResponseDto>
                {
                    Success = false,
                    Message = "Invalid username or password"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error logging in");
                return new ApiResponse<AuthResponseDto>
                {
                    Success = false,
                    Message = "Internal server error",
                    Errors = new[] { ex.Message }
                };
            }
        }
    }
}