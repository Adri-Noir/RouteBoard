using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class add_crag_creators : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CragCreators",
                columns: table => new
                {
                    CragId = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CragCreators", x => new { x.CragId, x.UserId });
                    table.ForeignKey(
                        name: "FK_CragCreators_Crags_CragId",
                        column: x => x.CragId,
                        principalTable: "Crags",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CragCreators_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CragCreators_UserId",
                table: "CragCreators",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CragCreators");
        }
    }
}
