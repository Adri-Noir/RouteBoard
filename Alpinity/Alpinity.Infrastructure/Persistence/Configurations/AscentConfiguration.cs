using System.Text.Json;
using Alpinity.Domain.Entities;
using Alpinity.Domain.Enums;
using Alpinity.Infrastructure.Persistence.Helpers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Alpinity.Infrastructure.Persistence.Configurations;

public class AscentConfiguration : IEntityTypeConfiguration<Ascent>
{
    public void Configure(EntityTypeBuilder<Ascent> builder)
    {
        builder.Property(a => a.ClimbTypes)
            .HasConversion(
                v => v != null ? JsonSerializer.Serialize(v, (JsonSerializerOptions)null!) : null,
                v => v != null ? JsonSerializer.Deserialize<ICollection<ClimbType>>(v, (JsonSerializerOptions)null!) : null
            )
            .Metadata.SetValueComparer(new CollectionValueComparer<ClimbType>());

        builder.Property(a => a.RockTypes)
            .HasConversion(
                v => v != null ? JsonSerializer.Serialize(v, (JsonSerializerOptions)null!) : null,
                v => v != null ? JsonSerializer.Deserialize<ICollection<RockType>>(v, (JsonSerializerOptions)null!) : null
            )
            .Metadata.SetValueComparer(new CollectionValueComparer<RockType>());

        builder.Property(a => a.HoldTypes)
            .HasConversion(
                v => v != null ? JsonSerializer.Serialize(v, (JsonSerializerOptions)null!) : null,
                v => v != null ? JsonSerializer.Deserialize<ICollection<HoldType>>(v, (JsonSerializerOptions)null!) : null
            )
            .Metadata.SetValueComparer(new CollectionValueComparer<HoldType>());
    }
} 