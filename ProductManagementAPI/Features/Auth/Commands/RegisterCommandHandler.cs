using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;
using ProductManagementAPI.Services;

namespace ProductManagementAPI.Features.Auth.Commands
{
    public class RegisterCommandHandler : IRequestHandler<RegisterCommand, ApiResponse<UserDto>>
    {
        private readonly IAuthService _authService;
        private readonly ILogger<RegisterCommandHandler> _logger;

        public RegisterCommandHandler(IAuthService authService, ILogger<RegisterCommandHandler> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        public async Task<ApiResponse<UserDto>> Handle(RegisterCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var user = await _authService.RegisterAsync(request.RegisterDto);
                if (user != null)
                {
                    return new ApiResponse<UserDto>
                    {
                        Success = true,
                        Data = new UserDto
                        {
                            Id = user.UserId,
                            UserName = user.UserName,
                            Email = user.Email
                        },
                        Message = "User registered successfully"
                    };
                }

                return new ApiResponse<UserDto>
                {
                    Success = false,
                    Message = "Username or Email already exists"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error registering user");
                return new ApiResponse<UserDto>
                {
                    Success = false,
                    Message = "Internal server error occurred",
                    Errors = new[] { ex.Message }
                };
            }
        }
    }
}