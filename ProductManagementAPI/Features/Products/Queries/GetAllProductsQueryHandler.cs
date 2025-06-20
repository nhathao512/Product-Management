using MediatR;
using Microsoft.EntityFrameworkCore;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;
using ProductManagementAPI.Repositories;

namespace ProductManagementAPI.Features.Products.Queries
{
    public class GetAllProductsQueryHandler : IRequestHandler<GetAllProductsQuery, ApiResponse<List<ProductDto>>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<GetAllProductsQueryHandler> _logger;

        public GetAllProductsQueryHandler(IUnitOfWork unitOfWork, ILogger<GetAllProductsQueryHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        public async Task<ApiResponse<List<ProductDto>>> Handle(GetAllProductsQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var query = _unitOfWork.Products.GetQueryable();

                // Tìm kiếm theo tên hoặc mô tả
                if (!string.IsNullOrWhiteSpace(request.Search))
                {
                    var searchLower = request.Search.ToLower();
                    query = query.Where(p => p.Name.ToLower().Contains(searchLower) ||
                                            (p.Description != null && p.Description.ToLower().Contains(searchLower)));
                }

                // Lọc theo trạng thái tồn kho
                if (request.InStock.HasValue)
                {
                    query = query.Where(p => p.Stock > 0 == request.InStock.Value);
                }

                // Sắp xếp
                if (!string.IsNullOrWhiteSpace(request.SortBy))
                {
                    bool isDescending = string.Equals(request.SortOrder, "desc", StringComparison.OrdinalIgnoreCase);
                    switch (request.SortBy.ToLower())
                    {
                        case "name":
                            query = isDescending ? query.OrderByDescending(p => p.Name) : query.OrderBy(p => p.Name);
                            break;
                        case "price":
                            query = isDescending ? query.OrderByDescending(p => p.Price) : query.OrderBy(p => p.Price);
                            break;
                        case "createdat":
                            query = isDescending ? query.OrderByDescending(p => p.CreatedAt) : query.OrderBy(p => p.CreatedAt);
                            break;
                        default:
                            query = query.OrderBy(p => p.Id); // Mặc định sắp xếp theo Id
                            break;
                    }
                }
                else
                {
                    query = query.OrderBy(p => p.Id); // Mặc định sắp xếp theo Id
                }

                // Phân trang
                int page = request.Page ?? 1;
                int limit = request.Limit ?? 20;
                if (page < 1) page = 1;
                if (limit < 1) limit = 20;
                int skip = (page - 1) * limit;
                query = query.Skip(skip).Take(limit);

                var products = await query.ToListAsync(cancellationToken);
                var productDtos = products.Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description ?? string.Empty,
                    Price = p.Price,
                    Stock = p.Stock,
                    ImageUrl = p.ImageUrl,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                }).ToList();

                return new ApiResponse<List<ProductDto>>
                {
                    Success = true,
                    Data = productDtos,
                    Message = "Products retrieved successfully"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving products");
                return new ApiResponse<List<ProductDto>>
                {
                    Success = false,
                    Message = "Internal server error",
                    Errors = new[] { ex.Message }
                };
            }
        }
    }
}