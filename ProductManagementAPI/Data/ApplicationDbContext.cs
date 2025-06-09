using Microsoft.EntityFrameworkCore;
using ProductManagementAPI.Models;

namespace ProductManagementAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Product>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Description).HasMaxLength(500);
                entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETDATE()");
                entity.Property(e => e.UpdatedAt).HasDefaultValueSql("GETDATE()");
            });

            modelBuilder.Entity<Product>().HasData(
                new Product
                {
                    Id = 1,
                    Name = "Laptop Dell",
                    Description = "Laptop Dell Inspiron 15",
                    Price = 15000000,
                    Stock = 10,
                    CreatedAt = new DateTime(2025, 6, 9, 14, 35, 0), 
                    UpdatedAt = new DateTime(2025, 6, 9, 14, 35, 0)  
                },
                new Product
                {
                    Id = 2,
                    Name = "iPhone 14",
                    Description = "Apple iPhone 14 Pro Max",
                    Price = 25000000,
                    Stock = 5,
                    CreatedAt = new DateTime(2025, 6, 9, 14, 35, 0), 
                    UpdatedAt = new DateTime(2025, 6, 9, 14, 35, 0)  
                },
                new Product
                {
                    Id = 3,
                    Name = "Samsung Galaxy S23",
                    Description = "Samsung Galaxy S23 Ultra",
                    Price = 22000000,
                    Stock = 8,
                    CreatedAt = new DateTime(2025, 6, 9, 14, 35, 0), // Static value
                    UpdatedAt = new DateTime(2025, 6, 9, 14, 35, 0)  // Static value
                }
            );
        }
    }
}