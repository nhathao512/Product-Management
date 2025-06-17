using Microsoft.AspNetCore.Mvc;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;
using ProductManagementAPI.Services;

namespace ProductManagementAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        [HttpPost("register")]
        public async Task<ActionResult> Register([FromBody] RegisterDto registerDto)
        {
            try
            {
                var user = await _authService.RegisterAsync(registerDto);
                if (user != null) 
                {
                    return Ok(new ApiResponse<UserDto>
                    {
                        Success = true,
                        Data = new UserDto
                        {
                            Id = user.UserId,
                            UserName = user.UserName,
                            Email = user.Email
                        },
                        Message = "User registered successfully"
                    });
                }

                return BadRequest(new ApiResponse<UserDto>
                {
                    Success = false,
                    Message = "Username or Email already exists"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error registering user");
                return StatusCode(500, new ApiResponse<UserDto>
                {
                    Success = false,
                    Message = "Internal server error occurred",
                    Errors = new[] { ex.Message }
                });
            }
        }

        [HttpPost("login")]
        public async Task<ActionResult> Login([FromBody] LoginDto loginDto)
        {
            try
            {
                var authResponse = await _authService.LoginAsync(loginDto);
                if (authResponse != null)
                {
                    return Ok(new ApiResponse<AuthResponseDto>
                    {
                        Success = true,
                        Data = authResponse,
                        Message = "Login successful"
                    });
                }

                return Unauthorized(new ApiResponse<AuthResponseDto>
                {
                    Success = false,
                    Message = "Invalid username or password"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error logging in");
                return StatusCode(500, new ApiResponse<AuthResponseDto>
                {
                    Success = false,
                    Message = "Internal server error",
                    Errors = new[] { ex.Message }
                });
            };
        }
    }
}
