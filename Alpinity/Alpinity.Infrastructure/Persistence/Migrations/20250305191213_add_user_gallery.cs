using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class add_user_gallery : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "UserPhotoGalleryId",
                table: "Photos",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Photos_UserPhotoGalleryId",
                table: "Photos",
                column: "UserPhotoGalleryId");

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_Users_UserPhotoGalleryId",
                table: "Photos",
                column: "UserPhotoGalleryId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Photos_Users_UserPhotoGalleryId",
                table: "Photos");

            migrationBuilder.DropIndex(
                name: "IX_Photos_UserPhotoGalleryId",
                table: "Photos");

            migrationBuilder.DropColumn(
                name: "UserPhotoGalleryId",
                table: "Photos");
        }
    }
}
