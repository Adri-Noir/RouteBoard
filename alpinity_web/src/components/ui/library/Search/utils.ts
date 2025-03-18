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
  } = suggestion;

  const type = entityType ? mapEntityTypeToUiType(entityType) : "crag";

  switch (type) {
    case "crag":
      return {
        count: cragRoutesCount,
        countLabel: "routes",
      };
    case "sector":
      return {
        parentName: sectorCragName,
        count: sectorRoutesCount,
        countLabel: "routes",
      };
    case "route":
      return {
        parentName: routeSectorName && routeCragName ? `${routeSectorName}, ${routeCragName}` : undefined,
        difficulty: routeDifficulty ? formatClimbingGrade(routeDifficulty) : undefined,
      };
    default:
      return {};
  }
};
