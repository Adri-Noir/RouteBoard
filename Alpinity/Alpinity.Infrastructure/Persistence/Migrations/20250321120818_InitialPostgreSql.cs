using System;
using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;

#nullable disable

namespace Alpinity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialPostgreSql : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("Npgsql:PostgresExtension:postgis", ",,");

            migrationBuilder.CreateTable(
                name: "Crags",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    Location = table.Column<Point>(type: "geometry", nullable: true),
                    LocationName = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Crags", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Username = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    FirstName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    LastName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CragWeathers",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CragId = table.Column<Guid>(type: "uuid", nullable: false),
                    Timestamp = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    WeatherData = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CragWeathers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CragWeathers_Crags_CragId",
                        column: x => x.CragId,
                        principalTable: "Crags",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Sectors",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    Location = table.Column<Point>(type: "geometry", nullable: true),
                    CragId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sectors", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Sectors_Crags_CragId",
                        column: x => x.CragId,
                        principalTable: "Crags",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Photos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Description = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    Url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    TakenAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    TakenByUserId = table.Column<Guid>(type: "uuid", nullable: true),
                    CragId = table.Column<Guid>(type: "uuid", nullable: true),
                    SectorId = table.Column<Guid>(type: "uuid", nullable: true),
                    RouteImageId = table.Column<Guid>(type: "uuid", nullable: true),
                    RoutePathLineId = table.Column<Guid>(type: "uuid", nullable: true),
                    UserPhotoId = table.Column<Guid>(type: "uuid", nullable: true),
                    UserPhotoGalleryId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Photos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Photos_Crags_CragId",
                        column: x => x.CragId,
                        principalTable: "Crags",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Photos_Sectors_SectorId",
                        column: x => x.SectorId,
                        principalTable: "Sectors",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Photos_Users_TakenByUserId",
                        column: x => x.TakenByUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Photos_Users_UserPhotoGalleryId",
                        column: x => x.UserPhotoGalleryId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Photos_Users_UserPhotoId",
                        column: x => x.UserPhotoId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Routes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    Grade = table.Column<int>(type: "integer", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    RouteType = table.Column<string>(type: "text", nullable: true),
                    Length = table.Column<int>(type: "integer", nullable: true),
                    SectorId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Routes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Routes_Sectors_SectorId",
                        column: x => x.SectorId,
                        principalTable: "Sectors",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Ascents",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    AscentDate = table.Column<DateOnly>(type: "date", nullable: false),
                    Notes = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    ClimbTypes = table.Column<string>(type: "text", nullable: true),
                    RockTypes = table.Column<string>(type: "text", nullable: true),
                    HoldTypes = table.Column<string>(type: "text", nullable: true),
                    AscentType = table.Column<int>(type: "integer", nullable: true),
                    NumberOfAttempts = table.Column<int>(type: "integer", nullable: true),
                    ProposedGrade = table.Column<int>(type: "integer", nullable: true),
                    Rating = table.Column<int>(type: "integer", nullable: true),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    RouteId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Ascents", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Ascents_Routes_RouteId",
                        column: x => x.RouteId,
                        principalTable: "Routes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Ascents_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "RoutePhotos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RouteId = table.Column<Guid>(type: "uuid", nullable: false),
                    ImageId = table.Column<Guid>(type: "uuid", nullable: false),
                    PathLineId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RoutePhotos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RoutePhotos_Photos_ImageId",
                        column: x => x.ImageId,
                        principalTable: "Photos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RoutePhotos_Photos_PathLineId",
                        column: x => x.PathLineId,
                        principalTable: "Photos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RoutePhotos_Routes_RouteId",
                        column: x => x.RouteId,
                        principalTable: "Routes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SearchHistories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EntityType = table.Column<int>(type: "integer", nullable: false),
                    CragId = table.Column<Guid>(type: "uuid", nullable: true),
                    SectorId = table.Column<Guid>(type: "uuid", nullable: true),
                    RouteId = table.Column<Guid>(type: "uuid", nullable: true),
                    ProfileUserId = table.Column<Guid>(type: "uuid", nullable: true),
                    SearchingUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    SearchedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SearchHistories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SearchHistories_Crags_CragId",
                        column: x => x.CragId,
                        principalTable: "Crags",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SearchHistories_Routes_RouteId",
                        column: x => x.RouteId,
                        principalTable: "Routes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SearchHistories_Sectors_SectorId",
                        column: x => x.SectorId,
                        principalTable: "Sectors",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SearchHistories_Users_ProfileUserId",
                        column: x => x.ProfileUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SearchHistories_Users_SearchingUserId",
                        column: x => x.SearchingUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Ascents_RouteId",
                table: "Ascents",
                column: "RouteId");

            migrationBuilder.CreateIndex(
                name: "IX_Ascents_UserId",
                table: "Ascents",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_CragWeathers_CragId",
                table: "CragWeathers",
                column: "CragId");

            migrationBuilder.CreateIndex(
                name: "IX_Photos_CragId",
                table: "Photos",
                column: "CragId");

            migrationBuilder.CreateIndex(
                name: "IX_Photos_SectorId",
                table: "Photos",
                column: "SectorId");

            migrationBuilder.CreateIndex(
                name: "IX_Photos_TakenByUserId",
                table: "Photos",
                column: "TakenByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Photos_UserPhotoGalleryId",
                table: "Photos",
                column: "UserPhotoGalleryId");

            migrationBuilder.CreateIndex(
                name: "IX_Photos_UserPhotoId",
                table: "Photos",
                column: "UserPhotoId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RoutePhotos_ImageId",
                table: "RoutePhotos",
                column: "ImageId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RoutePhotos_PathLineId",
                table: "RoutePhotos",
                column: "PathLineId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RoutePhotos_RouteId",
                table: "RoutePhotos",
                column: "RouteId");

            migrationBuilder.CreateIndex(
                name: "IX_Routes_SectorId",
                table: "Routes",
                column: "SectorId");

            migrationBuilder.CreateIndex(
                name: "IX_SearchHistories_CragId",
                table: "SearchHistories",
                column: "CragId");

            migrationBuilder.CreateIndex(
                name: "IX_SearchHistories_ProfileUserId",
                table: "SearchHistories",
                column: "ProfileUserId");

            migrationBuilder.CreateIndex(
                name: "IX_SearchHistories_RouteId",
                table: "SearchHistories",
                column: "RouteId");

            migrationBuilder.CreateIndex(
                name: "IX_SearchHistories_SearchingUserId",
                table: "SearchHistories",
                column: "SearchingUserId");

            migrationBuilder.CreateIndex(
                name: "IX_SearchHistories_SectorId",
                table: "SearchHistories",
                column: "SectorId");

            migrationBuilder.CreateIndex(
                name: "IX_Sectors_CragId",
                table: "Sectors",
                column: "CragId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Username",
                table: "Users",
                column: "Username",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Ascents");

            migrationBuilder.DropTable(
                name: "CragWeathers");

            migrationBuilder.DropTable(
                name: "RoutePhotos");

            migrationBuilder.DropTable(
                name: "SearchHistories");

            migrationBuilder.DropTable(
                name: "Photos");

            migrationBuilder.DropTable(
                name: "Routes");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Sectors");

            migrationBuilder.DropTable(
                name: "Crags");
        }
    }
}
