using MediatR;
using Microsoft.EntityFrameworkCore;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;
using ProductManagementAPI.Repositories;
using ProductManagementAPI.Services;
using System.ComponentModel.DataAnnotations;

namespace ProductManagementAPI.Features.Products.Commands
{
    public class UpdateProductCommandHandler : IRequestHandler<UpdateProductCommand, ApiResponse<ProductDto>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IFileService _fileService;
        private readonly ILogger<UpdateProductCommandHandler> _logger;

        public UpdateProductCommandHandler(IUnitOfWork unitOfWork, IFileService fileService, ILogger<UpdateProductCommandHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _fileService = fileService;
            _logger = logger;
        }

        public async Task<ApiResponse<ProductDto>> Handle(UpdateProductCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var updateProductDto = request.UpdateProductDto;

                // Validate DTO
                var validationContext = new ValidationContext(updateProductDto);
                var validationResults = new List<ValidationResult>();
                if (!Validator.TryValidateObject(updateProductDto, validationContext, validationResults, true))
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Validation failed",
                        Errors = validationResults.Select(vr => vr.ErrorMessage).ToArray()
                    };
                }

                var product = await _unitOfWork.Products.GetByIdAsync(request.Id);
                if (product == null)
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product not found"
                    };
                }

                var trimmedName = updateProductDto?.Name?.Trim();
                var trimmedDescription = updateProductDto?.Description?.Trim();

                if (string.IsNullOrWhiteSpace(trimmedName))
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product name is required and cannot be empty"
                    };
                }

                if (updateProductDto?.Price <= 0)
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Price must be greater than 0"
                    };
                }

                if (updateProductDto?.Stock < 0)
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Stock cannot be negative"
                    };
                }

                if (updateProductDto?.Image != null)
                {
                    if (!_fileService.IsValidImageFile(updateProductDto.Image))
                    {
                        return new ApiResponse<ProductDto>
                        {
                            Success = false,
                            Message = "Invalid image file. Please upload a valid image (JPG, PNG, JPEG, WEBP) under 5MB."
                        };
                    }

                    try
                    {
                        if (!string.IsNullOrWhiteSpace(product.ImageUrl))
                        {
                            _fileService.DeleteFile(product.ImageUrl);
                        }

                        product.ImageUrl = await _fileService.SaveFileAsync(updateProductDto.Image, "products");
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to upload image for product update");
                        return new ApiResponse<ProductDto>
                        {
                            Success = false,
                            Message = "Failed to upload image",
                            Errors = new[] { ex.Message }
                        };
                    }
                }

                product.Name = trimmedName;
                product.Description = trimmedDescription ?? string.Empty;
                product.Price = updateProductDto.Price;
                product.Stock = updateProductDto.Stock;
                product.UpdatedAt = DateTime.Now;

                await _unitOfWork.Products.UpdateAsync(product);
                await _unitOfWork.SaveChangesAsync();

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
                    Message = "Product updated successfully"
                };
            }
            catch (DbUpdateConcurrencyException)
            {
                var exists = await _unitOfWork.Products.GetByIdAsync(request.Id) != null;
                if (!exists)
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product not found"
                    };
                }
                else
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product was modified by another user. Please refresh and try again."
                    };
                }
            }
            catch (DbUpdateException dbEx)
            {
                _logger.LogError(dbEx, "Database update error while updating product {ProductId}", request.Id);

                var errorMessage = "Failed to update product.";
                var errors = new List<string>();

                if (dbEx?.InnerException != null)
                {
                    var innerMessage = dbEx.InnerException.Message.ToLower();

                    if (innerMessage.Contains("duplicate") || innerMessage.Contains("unique"))
                    {
                        errorMessage = "A product with this information already exists.";
                        errors.Add("Duplicate entry detected");
                    }
                    else if (innerMessage.Contains("foreign key") || innerMessage.Contains("reference"))
                    {
                        errorMessage = "Invalid reference to related data.";
                        errors.Add("Foreign key constraint violation");
                    }
                    else if (innerMessage.Contains("string") || innerMessage.Contains("truncat"))
                    {
                        errorMessage = "One or more fields exceed maximum length.";
                        errors.Add("Data too long for field");
                    }
                    else if (innerMessage.Contains("check constraint"))
                    {
                        errorMessage = "Data validation failed. Please check price and stock values.";
                        errors.Add("Check constraint violation");
                    }
                    else
                    {
                        errors.Add(dbEx.InnerException.Message);
                    }
                }
                else
                {
                    errors.Add(dbEx.Message);
                }

                return new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = errorMessage,
                    Errors = errors.ToArray()
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error while updating product {ProductId}", request.Id);
                return new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = "An unexpected error occurred while updating the product",
                    Errors = new[] { ex.Message }
                };
            }
        }
    }
}