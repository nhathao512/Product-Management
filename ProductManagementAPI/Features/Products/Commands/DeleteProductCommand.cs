using MediatR;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Features.Products.Commands
{
    public class DeleteProductCommand : IRequest<ApiResponse<object>>
    {
        public int Id { get; set; }
    }
}