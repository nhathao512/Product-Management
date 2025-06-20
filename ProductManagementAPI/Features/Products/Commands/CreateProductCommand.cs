using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Features.Products.Commands
{
    public class CreateProductCommand : IRequest<ApiResponse<ProductDto>>
    {
        public CreateProductDto CreateProductDto { get; set; } = null!;
    }
}