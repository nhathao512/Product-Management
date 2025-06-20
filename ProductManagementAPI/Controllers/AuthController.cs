using MediatR;
using Microsoft.AspNetCore.Mvc;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Features.Auth.Commands;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IMediator _mediator;

        public AuthController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpPost("register")]
        public async Task<ActionResult> Register([FromBody] RegisterDto registerDto)
        {
            var command = new RegisterCommand { RegisterDto = registerDto };
            var result = await _mediator.Send(command);
            return result.Success ? Ok(result) : result.Message == "Username or Email already exists" ? BadRequest(result) : StatusCode(500, result);
        }

        [HttpPost("login")]
        public async Task<ActionResult> Login([FromBody] LoginDto loginDto)
        {
            var command = new LoginCommand { LoginDto = loginDto };
            var result = await _mediator.Send(command);
            return result.Success ? Ok(result) : result.Message == "Invalid username or password" ? Unauthorized(result) : StatusCode(500, result);
        }
    }
}