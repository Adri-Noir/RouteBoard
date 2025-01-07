using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class add_profile_pic_to_user : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Photos_Users_TakenByUserId",
                table: "Photos");

            migrationBuilder.AddColumn<Guid>(
                name: "UserPhotoId",
                table: "Photos",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Photos_UserPhotoId",
                table: "Photos",
                column: "UserPhotoId",
                unique: true,
                filter: "[UserPhotoId] IS NOT NULL");

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_Users_TakenByUserId",
                table: "Photos",
                column: "TakenByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_Users_UserPhotoId",
                table: "Photos",
                column: "UserPhotoId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Photos_Users_TakenByUserId",
                table: "Photos");

            migrationBuilder.DropForeignKey(
                name: "FK_Photos_Users_UserPhotoId",
                table: "Photos");

            migrationBuilder.DropIndex(
                name: "IX_Photos_UserPhotoId",
                table: "Photos");

            migrationBuilder.DropColumn(
                name: "UserPhotoId",
                table: "Photos");

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_Users_TakenByUserId",
                table: "Photos",
                column: "TakenByUserId",
                principalTable: "Users",
                principalColumn: "Id");
        }
    }
}
