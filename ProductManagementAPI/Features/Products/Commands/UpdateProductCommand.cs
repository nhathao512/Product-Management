using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Features.Products.Commands
{
    public class UpdateProductCommand : IRequest<ApiResponse<ProductDto>>
    {
        public int Id { get; set; }
        public UpdateProductDto UpdateProductDto { get; set; } = null!;
    }
}