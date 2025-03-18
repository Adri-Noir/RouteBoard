import { SearchResultDto, SearchResultItemType } from "@/lib/api/types.gen";

export type GroupedSuggestions = Record<SearchResultItemType, SearchResultDto[]>;
