namespace Alpinity.Domain.Enums;

[Flags]
public enum RockType
{
    Vertical = 0,
    Overhang = 1,
    Roof = 2,
    Slab = 4,
    Arete = 8,
    Dihedral = 16
}