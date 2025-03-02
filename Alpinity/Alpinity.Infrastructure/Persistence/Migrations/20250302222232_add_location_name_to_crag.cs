using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class add_location_name_to_crag : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<Point>(
                name: "Location",
                table: "Crags",
                type: "geography",
                nullable: true,
                oldClrType: typeof(Point),
                oldType: "geography");

            migrationBuilder.AddColumn<string>(
                name: "LocationName",
                table: "Crags",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LocationName",
                table: "Crags");

            migrationBuilder.AlterColumn<Point>(
                name: "Location",
                table: "Crags",
                type: "geography",
                nullable: false,
                oldClrType: typeof(Point),
                oldType: "geography",
                oldNullable: true);
        }
    }
}
