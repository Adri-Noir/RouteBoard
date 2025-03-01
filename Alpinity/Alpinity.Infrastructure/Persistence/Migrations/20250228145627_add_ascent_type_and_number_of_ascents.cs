using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class add_ascent_type_and_number_of_ascents : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AscentType",
                table: "Ascents",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "NumberOfAttempts",
                table: "Ascents",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AscentType",
                table: "Ascents");

            migrationBuilder.DropColumn(
                name: "NumberOfAttempts",
                table: "Ascents");
        }
    }
}
