using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class add_location_to_sector : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Point>(
                name: "Location",
                table: "Sectors",
                type: "geography",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Location",
                table: "Sectors");
        }
    }
}
