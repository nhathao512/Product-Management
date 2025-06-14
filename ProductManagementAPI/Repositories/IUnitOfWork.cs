namespace ProductManagementAPI.Repositories
{
    public interface IUnitOfWork : IDisposable
    {
        IRepository<ProductManagementAPI.Models.Product> Products { get; }
        Task<int> SaveChangesAsync();
    }
}