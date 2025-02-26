using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using Alpinity.Infrastructure.Persistence.Helpers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System.Text.Json;

namespace Alpinity.Infrastructure.Persistence.Configurations;

public class RouteConfiguration : IEntityTypeConfiguration<Route>
{
    public void Configure(EntityTypeBuilder<Route> builder)
    {
        builder.Property(r => r.RouteType)
            .HasConversion(
                v => v != null ? JsonSerializer.Serialize(v, (JsonSerializerOptions)null!) : null,
                v => v != null ? JsonSerializer.Deserialize<ICollection<RouteType>>(v, (JsonSerializerOptions)null!) : null
            )
            .Metadata.SetValueComparer(new CollectionValueComparer<RouteType>());
    }
} 