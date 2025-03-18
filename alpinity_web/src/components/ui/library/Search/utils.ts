import { SearchResultDto, SearchResultItemType } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils";
import { SearchSuggestion, SearchSuggestionType } from "./types";

// Map API entity type to UI type
export const mapEntityTypeToUiType = (type: SearchResultItemType): SearchSuggestionType => {
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

// Map SearchResultDto to Suggestion
export const mapSearchResultToSuggestion = (result: SearchResultDto): SearchSuggestion => {
  const type = mapEntityTypeToUiType(result.entityType || "Crag");

  let text = "";
  switch (type) {
    case "crag":
      text = result.cragName || "";
      break;
    case "sector":
      text = result.sectorName || "";
      break;
    case "route":
      text = result.routeName || "";
      break;
    case "user":
      text = result.profileUsername || "";
      break;
  }

  return {
    text,
    type,
    id: result.id || "",
    entityData: result,
  };
};

// Format display data for different entity types
export const getFormattedEntityData = (suggestion: SearchSuggestion) => {
  const { type, entityData } = suggestion;

  switch (type) {
    case "crag":
      return {
        count: entityData.cragRoutesCount,
        countLabel: "routes",
      };
    case "sector":
      return {
        parentName: entityData.sectorCragName,
        count: entityData.sectorRoutesCount,
        countLabel: "routes",
      };
    case "route":
      return {
        parentName:
          entityData.routeSectorName && entityData.routeCragName
            ? `${entityData.routeSectorName}, ${entityData.routeCragName}`
            : undefined,
        difficulty: entityData.routeDifficulty ? formatClimbingGrade(entityData.routeDifficulty) : undefined,
      };
    default:
      return {};
  }
};
