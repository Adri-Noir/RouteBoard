using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class changed_deletion_rules_by_adding_cascade : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Photos_Crags_CragId",
                table: "Photos");

            migrationBuilder.DropForeignKey(
                name: "FK_Photos_Sectors_SectorId",
                table: "Photos");

            migrationBuilder.DropForeignKey(
                name: "FK_SearchHistories_Crags_CragId",
                table: "SearchHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_SearchHistories_Routes_RouteId",
                table: "SearchHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_SearchHistories_Sectors_SectorId",
                table: "SearchHistories");

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_Crags_CragId",
                table: "Photos",
                column: "CragId",
                principalTable: "Crags",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_Sectors_SectorId",
                table: "Photos",
                column: "SectorId",
                principalTable: "Sectors",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_SearchHistories_Crags_CragId",
                table: "SearchHistories",
                column: "CragId",
                principalTable: "Crags",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_SearchHistories_Routes_RouteId",
                table: "SearchHistories",
                column: "RouteId",
                principalTable: "Routes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_SearchHistories_Sectors_SectorId",
                table: "SearchHistories",
                column: "SectorId",
                principalTable: "Sectors",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Photos_Crags_CragId",
                table: "Photos");

            migrationBuilder.DropForeignKey(
                name: "FK_Photos_Sectors_SectorId",
                table: "Photos");

            migrationBuilder.DropForeignKey(
                name: "FK_SearchHistories_Crags_CragId",
                table: "SearchHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_SearchHistories_Routes_RouteId",
                table: "SearchHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_SearchHistories_Sectors_SectorId",
                table: "SearchHistories");

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_Crags_CragId",
                table: "Photos",
                column: "CragId",
                principalTable: "Crags",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_Sectors_SectorId",
                table: "Photos",
                column: "SectorId",
                principalTable: "Sectors",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_SearchHistories_Crags_CragId",
                table: "SearchHistories",
                column: "CragId",
                principalTable: "Crags",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_SearchHistories_Routes_RouteId",
                table: "SearchHistories",
                column: "RouteId",
                principalTable: "Routes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_SearchHistories_Sectors_SectorId",
                table: "SearchHistories",
                column: "SectorId",
                principalTable: "Sectors",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
