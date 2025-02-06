namespace Alpinity.Domain.Enums;

[Flags]
public enum RouteType
{
    Boulder = 0,
    Sport = 1,
    Trad = 2,
    MultiPitch = 4,
    Ice = 8,
    BigWall = 16,
    Mixed = 32,
    Aid = 64,
    ViaFerrata = 128
}