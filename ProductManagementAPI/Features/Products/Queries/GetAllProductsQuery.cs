using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Features.Products.Queries
{
    public class GetAllProductsQuery : IRequest<ApiResponse<List<ProductDto>>>
    {
        public string? Search { get; set; }
        public string? SortBy { get; set; }
        public string? SortOrder { get; set; }
        public bool? InStock { get; set; }
        public int? Page { get; set; }
        public int? Limit { get; set; }
    }
}