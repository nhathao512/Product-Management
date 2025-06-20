using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Features.Products.Commands;
using ProductManagementAPI.Features.Products.Queries;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ProductsController : ControllerBase
    {
        private readonly IMediator _mediator;

        public ProductsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        // GET: api/products?search=phone&sortBy=price&sortOrder=asc&inStock=true&page=1&limit=20
        [HttpGet]
        public async Task<ActionResult<ApiResponse<List<ProductDto>>>> GetProducts(
            [FromQuery] string? search,
            [FromQuery] string? sortBy,
            [FromQuery] string? sortOrder,
            [FromQuery] bool? inStock,
            [FromQuery] int? page,
            [FromQuery] int? limit)
        {
            var query = new GetAllProductsQuery
            {
                Search = search,
                SortBy = sortBy,
                SortOrder = sortOrder,
                InStock = inStock,
                Page = page,
                Limit = limit
            };
            var result = await _mediator.Send(query);
            return result.Success ? Ok(result) : StatusCode(500, result);
        }

        // GET: api/products/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<ProductDto>>> GetProduct(int id)
        {
            var query = new GetProductByIdQuery { Id = id };
            var result = await _mediator.Send(query);
            return result.Success ? Ok(result) : result.Message == "Product not found" ? NotFound(result) : StatusCode(500, result);
        }

        // POST: api/products
        [HttpPost]
        public async Task<ActionResult<ApiResponse<ProductDto>>> CreateProduct([FromForm] CreateProductDto createProductDto)
        {
            var command = new CreateProductCommand { CreateProductDto = createProductDto };
            var result = await _mediator.Send(command);
            if (!result.Success)
            {
                return result.Errors?.Any() ?? false ? BadRequest(result) : StatusCode(500, result);
            }
            return CreatedAtAction(nameof(GetProduct), new { id = result.Data?.Id }, result);
        }

        // PUT: api/products/5
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<ProductDto>>> UpdateProduct(int id, [FromForm] UpdateProductDto updateProductDto)
        {
            var command = new UpdateProductCommand { Id = id, UpdateProductDto = updateProductDto };
            var result = await _mediator.Send(command);
            if (!result.Success)
            {
                return result.Message == "Product not found" ? NotFound(result) :
                       result.Message.Contains("modified by another user") ? Conflict(result) :
                       result.Errors?.Any() ?? false ? BadRequest(result) : StatusCode(500, result);
            }
            return Ok(result);
        }

        // DELETE: api/products/5
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteProduct(int id)
        {
            var command = new DeleteProductCommand { Id = id };
            var result = await _mediator.Send(command);
            return result.Success ? Ok(result) : result.Message == "Product not found" ? NotFound(result) : StatusCode(500, result);
        }
    }
}