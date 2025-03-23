"use client";

import {
  CommandDialog,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandList,
  CommandSeparator,
} from "@/components/ui/command";
import { getApiUserSearchHistoryOptions, postApiSearchOptions } from "@/lib/api/@tanstack/react-query.gen";
import { SearchResultDto } from "@/lib/api/types.gen";
import useAuth from "@/lib/hooks/useAuth";
import { useDebounce } from "@/lib/hooks/useDebounce";
import { useQuery } from "@tanstack/react-query";
import { useCallback, useEffect, useMemo, useState } from "react";
import { SearchSuggestionItem } from "./SearchSuggestionItem";
import { GroupedSuggestions } from "./types";

interface SearchDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  inputPlaceholder?: string;
}

export const SearchDialog = ({
  open,
  onOpenChange,
  inputPlaceholder = "Search for crags, sectors, routes or users...",
}: SearchDialogProps) => {
  const { isAuthenticated } = useAuth();
  const [inputValue, setInputValue] = useState("");

  // Debounce the search query to avoid excessive API calls
  const searchQuery = useDebounce(inputValue, 300);

  // Skip the query if the search query is empty
  const shouldFetch = searchQuery.trim().length > 1;

  const { data: searchData, isLoading: isLoadingSearch } = useQuery({
    ...postApiSearchOptions({
      body: {
        query: searchQuery,
      },
    }),
    enabled: shouldFetch && open && isAuthenticated,
  });

  const { data: searchHistoryData = [] } = useQuery({
    ...getApiUserSearchHistoryOptions(),
    enabled: open && isAuthenticated,
  });

  // Handle input change
  const handleInputChange = useCallback((value: string) => {
    setInputValue(value);
  }, []);

  // Group suggestions by type
  const grouped = useMemo(() => {
    const grouped: GroupedSuggestions = {
      Crag: [],
      Sector: [],
      Route: [],
      UserProfile: [],
    };

    searchData?.forEach((suggestion) => {
      if (suggestion.entityType) {
        grouped[suggestion.entityType].push(suggestion);
      }
    });

    return grouped;
  }, [searchData]);

  useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if ((e.key === "k" && (e.metaKey || e.ctrlKey)) || e.key === "/") {
        e.preventDefault();
        onOpenChange(!open);
      }
    };

    document.addEventListener("keydown", down);
    return () => document.removeEventListener("keydown", down);
  }, [open, onOpenChange]);

  const hasCrags = grouped["Crag"].length > 0;
  const hasSectors = grouped["Sector"].length > 0;
  const hasRoutes = grouped["Route"].length > 0;
  const hasUsers = grouped["UserProfile"].length > 0;
  const hasRecentSearches = searchHistoryData.length > 0;
  const hasSearchResults = hasCrags || hasSectors || hasRoutes || hasUsers;
  const showRecent = !inputValue.trim() && hasRecentSearches;
  const showResults = shouldFetch && hasSearchResults;

  if (!isAuthenticated) {
    return null;
  }

  return (
    <CommandDialog open={open} onOpenChange={onOpenChange}>
      <CommandInput placeholder={inputPlaceholder} value={inputValue} onValueChange={handleInputChange} autoFocus />
      <CommandList>
        {isLoadingSearch && shouldFetch && (
          <div className="flex items-center justify-center py-6">
            <div className="border-primary h-4 w-4 animate-spin rounded-full border-2 border-t-transparent"></div>
          </div>
        )}

        {/* Show recent searches when no input */}
        {showRecent && (
          <CommandGroup heading="Recent Searches">
            {searchHistoryData.slice(0, 5).map((recent: SearchResultDto) => (
              <SearchSuggestionItem
                key={`recent-${recent.id}`}
                suggestion={recent}
                isRecent={true}
                onClick={() => onOpenChange(false)}
              />
            ))}
          </CommandGroup>
        )}

        {/* Show separator when both recent searches and results are visible */}
        {showRecent && showResults && <CommandSeparator />}

        {/* No results message */}
        {shouldFetch && !isLoadingSearch && !hasSearchResults && <CommandEmpty>No results found</CommandEmpty>}

        {/* Render grouped results */}
        {hasCrags && (
          <CommandGroup heading="Crags">
            {grouped.Crag.map((suggestion: SearchResultDto) => (
              <SearchSuggestionItem
                key={`crag-${suggestion.id}`}
                suggestion={suggestion}
                onClick={() => onOpenChange(false)}
              />
            ))}
          </CommandGroup>
        )}

        {hasSectors && (
          <CommandGroup heading="Sectors">
            {grouped.Sector.map((suggestion: SearchResultDto) => (
              <SearchSuggestionItem
                key={`sector-${suggestion.id}`}
                suggestion={suggestion}
                onClick={() => onOpenChange(false)}
              />
            ))}
          </CommandGroup>
        )}

        {hasRoutes && (
          <CommandGroup heading="Routes">
            {grouped.Route.map((suggestion: SearchResultDto) => (
              <SearchSuggestionItem
                key={`route-${suggestion.id}`}
                suggestion={suggestion}
                onClick={() => onOpenChange(false)}
              />
            ))}
          </CommandGroup>
        )}

        {hasUsers && (
          <CommandGroup heading="Users">
            {grouped.UserProfile.map((suggestion: SearchResultDto) => (
              <SearchSuggestionItem
                key={`user-${suggestion.id}`}
                suggestion={suggestion}
                onClick={() => onOpenChange(false)}
              />
            ))}
          </CommandGroup>
        )}
      </CommandList>
    </CommandDialog>
  );
};

export default SearchDialog;
