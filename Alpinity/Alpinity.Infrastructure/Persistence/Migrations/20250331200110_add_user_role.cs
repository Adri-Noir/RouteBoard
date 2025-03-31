using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class add_user_role : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "UserRole",
                table: "Users",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "UserRole",
                table: "Users");
        }
    }
}
