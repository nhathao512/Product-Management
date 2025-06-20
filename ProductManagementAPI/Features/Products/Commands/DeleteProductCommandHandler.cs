using MediatR;
using ProductManagementAPI.Models;
using ProductManagementAPI.Repositories;
using ProductManagementAPI.Services;

namespace ProductManagementAPI.Features.Products.Commands
{
    public class DeleteProductCommandHandler : IRequestHandler<DeleteProductCommand, ApiResponse<object>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IFileService _fileService;
        private readonly ILogger<DeleteProductCommandHandler> _logger;

        public DeleteProductCommandHandler(IUnitOfWork unitOfWork, IFileService fileService, ILogger<DeleteProductCommandHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _fileService = fileService;
            _logger = logger;
        }

        public async Task<ApiResponse<object>> Handle(DeleteProductCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var product = await _unitOfWork.Products.GetByIdAsync(request.Id);
                if (product == null)
                {
                    return new ApiResponse<object>
                    {
                        Success = false,
                        Message = "Product not found"
                    };
                }

                if (!string.IsNullOrWhiteSpace(product.ImageUrl))
                {
                    _fileService.DeleteFile(product.ImageUrl);
                }

                await _unitOfWork.Products.DeleteAsync(product);
                await _unitOfWork.SaveChangesAsync();

                return new ApiResponse<object>
                {
                    Success = true,
                    Message = "Product deleted successfully"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting product {ProductId}", request.Id);
                return new ApiResponse<object>
                {
                    Success = false,
                    Message = "Internal server error",
                    Errors = new[] { ex.Message }
                };
            }
        }
    }
}