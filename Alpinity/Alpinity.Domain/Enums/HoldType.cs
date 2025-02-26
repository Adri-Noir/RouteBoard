namespace Alpinity.Domain.Enums;

[Flags]
public enum HoldType
{
    Crack = 0,
    Crimps = 1,
    Slopers = 2,
    Pinches = 4,
    Jugs = 8,
    Pockets = 16
}