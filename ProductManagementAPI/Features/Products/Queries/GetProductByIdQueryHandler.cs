using MediatR;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;
using ProductManagementAPI.Repositories;

namespace ProductManagementAPI.Features.Products.Queries
{
    public class GetProductByIdQueryHandler : IRequestHandler<GetProductByIdQuery, ApiResponse<ProductDto>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<GetProductByIdQueryHandler> _logger;

        public GetProductByIdQueryHandler(IUnitOfWork unitOfWork, ILogger<GetProductByIdQueryHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        public async Task<ApiResponse<ProductDto>> Handle(GetProductByIdQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var product = await _unitOfWork.Products.GetByIdAsync(request.Id);

                if (product == null)
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product not found"
                    };
                }

                var productDto = new ProductDto
                {
                    Id = product.Id,
                    Name = product.Name,
                    Description = product.Description,
                    Price = product.Price,
                    Stock = product.Stock,
                    ImageUrl = product.ImageUrl,
                    CreatedAt = product.CreatedAt,
                    UpdatedAt = product.UpdatedAt
                };

                return new ApiResponse<ProductDto>
                {
                    Success = true,
                    Data = productDto,
                    Message = "Product retrieved successfully"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving product {ProductId}", request.Id);
                return new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = "Internal server error",
                    Errors = new[] { ex.Message }
                };
            }
        }
    }
}