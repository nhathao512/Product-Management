using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace ProductManagementAPI.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Products",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Stock = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Products", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "Id", "CreatedAt", "Description", "Name", "Price", "Stock", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 6, 9, 14, 35, 0, 0, DateTimeKind.Unspecified), "Laptop Dell Inspiron 15", "Laptop Dell", 15000000m, 10, new DateTime(2025, 6, 9, 14, 35, 0, 0, DateTimeKind.Unspecified) },
                    { 2, new DateTime(2025, 6, 9, 14, 35, 0, 0, DateTimeKind.Unspecified), "Apple iPhone 14 Pro Max", "iPhone 14", 25000000m, 5, new DateTime(2025, 6, 9, 14, 35, 0, 0, DateTimeKind.Unspecified) },
                    { 3, new DateTime(2025, 6, 9, 14, 35, 0, 0, DateTimeKind.Unspecified), "Samsung Galaxy S23 Ultra", "Samsung Galaxy S23", 22000000m, 8, new DateTime(2025, 6, 9, 14, 35, 0, 0, DateTimeKind.Unspecified) }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Products");
        }
    }
}
