using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Features.Products.Queries
{
    public class GetProductByIdQuery : IRequest<ApiResponse<ProductDto>>
    {
        public int Id { get; set; }
    }
}