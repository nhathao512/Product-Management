using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProductManagementAPI.Data;
using ProductManagementAPI.DTOs;
using ProductManagementAPI.Models;
using ProductManagementAPI.Services;
using System.Data.SqlClient;

namespace ProductManagementAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IFileService _fileService;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ApplicationDbContext context, IFileService fileService, ILogger<ProductsController> logger)
        {
            _context = context;
            _fileService = fileService;
            _logger = logger;
        }

        // GET: api/products
        [HttpGet]
        public async Task<ActionResult<ApiResponse<List<ProductDto>>>> GetProducts()
        {
            try
            {
                var products = await _context.Products
                    .Select(p => new ProductDto
                    {
                        Id = p.Id,
                        Name = p.Name,
                        Description = p.Description,
                        Price = p.Price,
                        Stock = p.Stock,
                        ImageUrl = p.ImageUrl,
                        CreatedAt = p.CreatedAt,
                        UpdatedAt = p.UpdatedAt
                    })
                    .ToListAsync();

                return Ok(new ApiResponse<List<ProductDto>>
                {
                    Success = true,
                    Data = products,
                    Message = "Products retrieved successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving products");
                return StatusCode(500, new ApiResponse<List<ProductDto>>
                {
                    Success = false,
                    Message = "Internal server error",
                    Errors = new[] { ex.Message }
                });
            }
        }

        // GET: api/products/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<ProductDto>>> GetProduct(int id)
        {
            try
            {
                var product = await _context.Products.FindAsync(id);

                if (product == null)
                {
                    return NotFound(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product not found"
                    });
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

                return Ok(new ApiResponse<ProductDto>
                {
                    Success = true,
                    Data = productDto,
                    Message = "Product retrieved successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving product {ProductId}", id);
                return StatusCode(500, new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = "Internal server error",
                    Errors = new[] { ex.Message }
                });
            }
        }

        // POST: api/products
        [HttpPost]
        public async Task<ActionResult<ApiResponse<ProductDto>>> CreateProduct([FromForm] CreateProductDto createProductDto)
        {
            try
            {
                // Validate ModelState
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values
                        .SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                        .ToArray();

                    return BadRequest(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Validation failed",
                        Errors = errors
                    });
                }

                // Validate and clean input data
                var trimmedName = createProductDto.Name?.Trim();
                var trimmedDescription = createProductDto.Description?.Trim();

                if (string.IsNullOrEmpty(trimmedName))
                {
                    return BadRequest(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product name is required and cannot be empty"
                    });
                }

                if (createProductDto.Price <= 0)
                {
                    return BadRequest(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Price must be greater than 0"
                    });
                }

                if (createProductDto.Stock < 0)
                {
                    return BadRequest(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Stock cannot be negative"
                    });
                }

                string? imageUrl = null;

                // Handle image upload
                if (createProductDto.Image != null)
                {
                    if (!_fileService.IsValidImageFile(createProductDto.Image))
                    {
                        return BadRequest(new ApiResponse<ProductDto>
                        {
                            Success = false,
                            Message = "Invalid image file. Please upload a valid image (JPG, PNG, GIF, WEBP) under 5MB."
                        });
                    }

                    try
                    {
                        imageUrl = await _fileService.SaveFileAsync(createProductDto.Image, "products");
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to upload image for product creation");
                        return StatusCode(500, new ApiResponse<ProductDto>
                        {
                            Success = false,
                            Message = "Failed to upload image",
                            Errors = new[] { ex.Message }
                        });
                    }
                }

                // Create product entity
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

                _context.Products.Add(product);
                await _context.SaveChangesAsync();

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

                return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, new ApiResponse<ProductDto>
                {
                    Success = true,
                    Data = productDto,
                    Message = "Product created successfully"
                });
            }
            catch (DbUpdateException dbEx)
            {
                _logger.LogError(dbEx, "Database update error while creating product");

                var errorMessage = "Failed to create product.";
                var errors = new List<string>();

                if (dbEx.InnerException != null)
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

                return BadRequest(new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = errorMessage,
                    Errors = errors.ToArray()
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error while creating product");
                return StatusCode(500, new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = "An unexpected error occurred while creating the product",
                    Errors = new[] { ex.Message }
                });
            }
        }

        // PUT: api/products/5
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<ProductDto>>> UpdateProduct(int id, [FromForm] UpdateProductDto updateProductDto)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values
                        .SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                        .ToArray();

                    return BadRequest(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Validation failed",
                        Errors = errors
                    });
                }

                var product = await _context.Products.FindAsync(id);
                if (product == null)
                {
                    return NotFound(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product not found"
                    });
                }

                // Validate and clean input data
                var trimmedName = updateProductDto.Name?.Trim();
                var trimmedDescription = updateProductDto.Description?.Trim();

                if (string.IsNullOrEmpty(trimmedName))
                {
                    return BadRequest(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product name is required and cannot be empty"
                    });
                }

                if (updateProductDto.Price <= 0)
                {
                    return BadRequest(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Price must be greater than 0"
                    });
                }

                if (updateProductDto.Stock < 0)
                {
                    return BadRequest(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Stock cannot be negative"
                    });
                }

                // Handle image upload
                if (updateProductDto.Image != null)
                {
                    if (!_fileService.IsValidImageFile(updateProductDto.Image))
                    {
                        return BadRequest(new ApiResponse<ProductDto>
                        {
                            Success = false,
                            Message = "Invalid image file. Please upload a valid image (JPG, PNG, GIF, WEBP) under 5MB."
                        });
                    }

                    try
                    {
                        // Delete old image if exists
                        if (!string.IsNullOrEmpty(product.ImageUrl))
                        {
                            _fileService.DeleteFile(product.ImageUrl);
                        }

                        // Upload new image
                        product.ImageUrl = await _fileService.SaveFileAsync(updateProductDto.Image, "products");
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to upload image for product update");
                        return StatusCode(500, new ApiResponse<ProductDto>
                        {
                            Success = false,
                            Message = "Failed to upload image",
                            Errors = new[] { ex.Message }
                        });
                    }
                }

                // Update product properties
                product.Name = trimmedName;
                product.Description = trimmedDescription ?? string.Empty;
                product.Price = updateProductDto.Price;
                product.Stock = updateProductDto.Stock;
                product.UpdatedAt = DateTime.Now;

                await _context.SaveChangesAsync();

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

                return Ok(new ApiResponse<ProductDto>
                {
                    Success = true,
                    Data = productDto,
                    Message = "Product updated successfully"
                });
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ProductExists(id))
                {
                    return NotFound(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product not found"
                    });
                }
                else
                {
                    return Conflict(new ApiResponse<ProductDto>
                    {
                        Success = false,
                        Message = "Product was modified by another user. Please refresh and try again."
                    });
                }
            }
            catch (DbUpdateException dbEx)
            {
                _logger.LogError(dbEx, "Database update error while updating product {ProductId}", id);

                var errorMessage = "Failed to update product.";
                var errors = new List<string>();

                if (dbEx.InnerException != null)
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

                return BadRequest(new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = errorMessage,
                    Errors = errors.ToArray()
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error while updating product {ProductId}", id);
                return StatusCode(500, new ApiResponse<ProductDto>
                {
                    Success = false,
                    Message = "An unexpected error occurred while updating the product",
                    Errors = new[] { ex.Message }
                });
            }
        }

        // DELETE: api/products/5
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteProduct(int id)
        {
            try
            {
                var product = await _context.Products.FindAsync(id);
                if (product == null)
                {
                    return NotFound(new ApiResponse<object>
                    {
                        Success = false,
                        Message = "Product not found"
                    });
                }

                // Delete image if exists
                if (!string.IsNullOrEmpty(product.ImageUrl))
                {
                    _fileService.DeleteFile(product.ImageUrl);
                }

                _context.Products.Remove(product);
                await _context.SaveChangesAsync();

                return Ok(new ApiResponse<object>
                {
                    Success = true,
                    Message = "Product deleted successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting product {ProductId}", id);
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = "Internal server error",
                    Errors = new[] { ex.Message }
                });
            }
        }

        private bool ProductExists(int id)
        {
            return _context.Products.Any(e => e.Id == id);
        }
    }
}