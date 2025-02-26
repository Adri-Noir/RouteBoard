using Microsoft.EntityFrameworkCore.ChangeTracking;

namespace Alpinity.Infrastructure.Persistence.Helpers;

/// <summary>
/// Custom value comparer for enum collections stored as JSON
/// </summary>
public class CollectionValueComparer<T> : ValueComparer<ICollection<T>>
{
    public CollectionValueComparer() : base(
        (c1, c2) => c1 != null && c2 != null && c1.SequenceEqual(c2),
        c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v!.GetHashCode())),
        c => c.ToList())
    {
    }
} 