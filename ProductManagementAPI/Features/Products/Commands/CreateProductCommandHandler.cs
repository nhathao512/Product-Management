using MediatR;
using Microsoft.EntityFrameworkCore;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;
using ProductManagementAPI.Repositories;
using ProductManagementAPI.Services;
using System.ComponentModel.DataAnnotations;

namespace ProductManagementAPI.Features.Products.Commands
{
    public class CreateProductCommandHandler : IRequestHandler<CreateProductCommand, ApiResponse<ProductDto>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IFileService _fileService;
        private readonly ILogger<CreateProductCommandHandler> _logger;

        public CreateProductCommandHandler(IUnitOfWork unitOfWork, IFileService fileService, ILogger<CreateProductCommandHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _fileService = fileService;
            _logger = logger;
        }

        public async Task<ApiResponse<ProductDto>> Handle(CreateProductCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var createProductDto = request.CreateProductDto;

                // Validate DTO
                var validationContext = new ValidationContext(createProductDto);
                var validationResults = new List<ValidationResult>();
                if (!Validator.TryValidateObject(createProductDto, validationContext, validationResults, true))
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Validation failed",
                        Errors = validationResults.Select(vr => vr.ErrorMessage).ToArray()
                    };
                }

                var trimmedName = createProductDto?.Name?.Trim();
                var trimmedDescription = createProductDto?.Description?.Trim();

                if (string.IsNullOrWhiteSpace(trimmedName))
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product name is required and cannot be empty"
                    };
                }

                if (createProductDto?.Price <= 0)
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Price must be greater than 0"
                    };
                }

                if (createProductDto?.Stock < 0)
                {
                    return new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Stock cannot be negative"
                    };
                }

                string? imageUrl = null;

                if (createProductDto?.Image != null)
                {
                    if (!_fileService.IsValidImageFile(createProductDto.Image))
                    {
                        return new ApiResponse<ProductDto>
                        {
                            Success = false,
                            Message = "Invalid image file. Please upload a valid image (JPG, PNG, JPEG, WEBP) under 100MB."
                        };
                    }

                    try
                    {
                        imageUrl = await _fileService.SaveFileAsync(createProductDto.Image, "products");
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to upload image for product creation");
                        return new ApiResponse<ProductDto>
                        {
                            Success = false,
                            Message = "Failed to upload image",
                            Errors = new[] { ex.Message }
                        };
                    }
                }

                var product = new Product
                {
                    Name = trimmedName,
                    Description = trimmedDescription ?? string.Empty,
                    Price = createProductDto.Price,
                    Stock = createProductDto.Stock,
                    ImageUrl = imageUrl,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                };

                await _unitOfWork.Products.AddAsync(product);
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
                    Message = "Product created successfully"
                };
            }
            catch (DbUpdateException dbEx)
            {
                _logger.LogError(dbEx, "Database update error while creating product");

                var errorMessage = "Failed to create product.";
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
                    else if (innerMessage.Contains("null") || innerMessage.Contains("required"))
                    {
                        errorMessage = "Required field is missing or null.";
                        errors.Add("Required field violation");
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
                _logger.LogError(ex, "Unexpected error while creating product");
                return new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = "An unexpected error occurred while creating the product",
                    Errors = new[] { ex.Message }
                };
            }
        }
    }
}