import { SearchResultDto } from "@/lib/api/types.gen";

export type SearchSuggestionType = "crag" | "sector" | "route" | "user";

export type SearchSuggestion = {
  text: string;
  type: SearchSuggestionType;
  id: string;
  entityData: SearchResultDto;
};

export type GroupedSuggestions = Record<SearchSuggestionType, SearchSuggestion[]>;
