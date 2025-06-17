import { SearchResultDto, SearchResultItemType } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils";

// Map API entity type to UI type
export const mapEntityTypeToUiType = (type: SearchResultItemType): string => {
  switch (type) {
    case "Crag":
      return "crag";
    case "Sector":
      return "sector";
    case "Route":
      return "route";
    case "UserProfile":
      return "user";
    default:
      return "crag"; // Fallback
  }
};

// Format display data for different entity types
export const getFormattedEntityData = (suggestion: SearchResultDto) => {
  const {
    entityType,
    cragRoutesCount,
    sectorCragName,
    sectorRoutesCount,
    routeSectorName,
    routeCragName,
    routeDifficulty,
    ascentsCount,
    cragSectorsCount,
  } = suggestion;

  const type = entityType ? mapEntityTypeToUiType(entityType) : "crag";

  switch (type) {
    case "crag":
      return {
        counts: [
          cragSectorsCount !== null && cragSectorsCount !== undefined
            ? { count: cragSectorsCount, label: "sectors" }
            : undefined,
          cragRoutesCount !== null && cragRoutesCount !== undefined
            ? { count: cragRoutesCount, label: "routes" }
            : undefined,
        ].filter(Boolean) as { count: number; label: string }[],
      } as const;
    case "sector":
      return {
        parentName: sectorCragName,
        counts: [
          sectorRoutesCount !== null && sectorRoutesCount !== undefined
            ? { count: sectorRoutesCount, label: "routes" }
            : undefined,
        ].filter(Boolean) as { count: number; label: string }[],
      } as const;
    case "route":
      return {
        parentName: routeSectorName && routeCragName ? `${routeSectorName}, ${routeCragName}` : undefined,
        difficulty: routeDifficulty ? formatClimbingGrade(routeDifficulty) : undefined,
      } as const;
    case "user":
      return {
        counts: [
          ascentsCount !== null && ascentsCount !== undefined ? { count: ascentsCount, label: "ascents" } : undefined,
        ].filter(Boolean) as { count: number; label: string }[],
      } as const;
    default:
      return {};
  }
};
