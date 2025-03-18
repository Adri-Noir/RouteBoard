"use client";

import { Button } from "@/components/ui/button";
import {
  CommandDialog,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
} from "@/components/ui/command";
import { getApiUserSearchHistoryOptions, postApiSearchOptions } from "@/lib/api/@tanstack/react-query.gen";
import { SearchResultDto, SearchResultItemType } from "@/lib/api/types.gen";
import useAuth from "@/lib/hooks/useAuth";
import { useDebounce } from "@/lib/hooks/useDebounce";
import { formatClimbingGrade } from "@/lib/utils";
import { useQuery } from "@tanstack/react-query";
import { Clock, MapPin, Route, User } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";

// Define the type first
type Suggestion = {
  text: string;
  type: "crag" | "sector" | "route" | "user";
  id: string;
  entityData: SearchResultDto;
};

// Map API entity type to our UI type
const mapEntityTypeToUiType = (type: SearchResultItemType): Suggestion["type"] => {
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
const mapSearchResultToSuggestion = (result: SearchResultDto): Suggestion => {
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

const HeroInput = () => {
  const { isAuthenticated } = useAuth();
  const [inputValue, setInputValue] = useState("");
  const [open, setOpen] = useState(false);

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

  const { data: searchHistoryData } = useQuery({
    ...getApiUserSearchHistoryOptions(),
    enabled: isAuthenticated,
  });

  // Process suggestions directly from the search data
  const suggestions = useMemo(() => {
    if (!searchData) return [];
    return searchData.map(mapSearchResultToSuggestion);
  }, [searchData]);

  // Process the search history
  const recentSearches = useMemo(() => {
    if (!searchHistoryData) return [];
    return searchHistoryData.map(mapSearchResultToSuggestion);
  }, [searchHistoryData]);

  const handleSuggestionClick = (suggestion: Suggestion) => {
    setInputValue(suggestion.text);
    setOpen(false);
    // Optionally trigger search immediately
    console.log("Selected suggestion:", suggestion);
  };

  // Handle input change
  const handleInputChange = useCallback((value: string) => {
    setInputValue(value);
  }, []);

  // Group suggestions by type
  const grouped = useMemo(() => {
    const grouped: Record<string, Suggestion[]> = {
      crag: [],
      sector: [],
      route: [],
      user: [],
    };

    suggestions.forEach((suggestion) => {
      grouped[suggestion.type].push(suggestion);
    });

    return grouped;
  }, [suggestions]);

  useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if ((e.key === "k" && (e.metaKey || e.ctrlKey)) || e.key === "/") {
        e.preventDefault();
        setOpen((open) => !open);
      }
    };

    document.addEventListener("keydown", down);
    return () => document.removeEventListener("keydown", down);
  }, []);

  const hasCrags = grouped.crag.length > 0;
  const hasSectors = grouped.sector.length > 0;
  const hasRoutes = grouped.route.length > 0;
  const hasUsers = grouped.user.length > 0;
  const hasRecentSearches = recentSearches.length > 0;
  const hasSearchResults = hasCrags || hasSectors || hasRoutes || hasUsers;
  const showRecent = !inputValue.trim() && hasRecentSearches;
  const showResults = shouldFetch && hasSearchResults;

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="mt-10 w-full max-w-lg">
      <Button
        onClick={() => setOpen(true)}
        variant="outline"
        className="text-muted-foreground w-full justify-between rounded-md bg-white/95 px-4 py-6 text-left"
      >
        <span>Search for crags, sectors, routes or users...</span>
        <kbd
          className="bg-muted text-muted-foreground pointer-events-none inline-flex h-5 items-center gap-1 rounded border px-1.5 font-mono
            text-[10px] font-medium select-none"
        >
          <span className="text-xs">⌘</span>K
        </kbd>
      </Button>

      <CommandDialog open={open} onOpenChange={setOpen}>
        <CommandInput
          placeholder="Search for crags, sectors, routes or users..."
          value={inputValue}
          onValueChange={handleInputChange}
          autoFocus
        />
        <CommandList>
          {isLoadingSearch && shouldFetch && (
            <div className="flex items-center justify-center py-6">
              <div className="border-primary h-4 w-4 animate-spin rounded-full border-2 border-t-transparent"></div>
            </div>
          )}

          {/* Show recent searches when no input */}
          {showRecent && (
            <CommandGroup heading="Recent Searches">
              {recentSearches.slice(0, 5).map((recent) => (
                <CommandItem
                  key={`recent-${recent.id}`}
                  value={`recent: ${recent.text}`}
                  onSelect={() => handleSuggestionClick(recent)}
                  className="flex items-center gap-2"
                >
                  <Clock className="text-muted-foreground h-4 w-4" />
                  <div className="flex flex-col">
                    <span>{recent.text}</span>
                    <span className="text-muted-foreground text-xs capitalize">{recent.type}</span>
                  </div>
                </CommandItem>
              ))}
            </CommandGroup>
          )}

          {/* Show separator when both recent searches and results are visible */}
          {showRecent && showResults && <CommandSeparator />}

          {/* No results message */}
          {shouldFetch && !isLoadingSearch && !hasSearchResults && <CommandEmpty>No results found</CommandEmpty>}

          {hasCrags && (
            <CommandGroup heading="Crags">
              {grouped.crag.map((suggestion) => (
                <CommandItem
                  key={`crag-${suggestion.id}`}
                  value={`crag: ${suggestion.text}`}
                  onSelect={() => handleSuggestionClick(suggestion)}
                  className="flex items-center gap-2"
                >
                  <MapPin className="text-muted-foreground h-4 w-4" />
                  <span>{suggestion.text}</span>
                  {suggestion.entityData.cragRoutesCount !== null && (
                    <span className="text-muted-foreground ml-auto text-xs">
                      {suggestion.entityData.cragRoutesCount} routes
                    </span>
                  )}
                </CommandItem>
              ))}
            </CommandGroup>
          )}

          {hasSectors && (
            <CommandGroup heading="Sectors">
              {grouped.sector.map((suggestion) => (
                <CommandItem
                  key={`sector-${suggestion.id}`}
                  value={`sector: ${suggestion.text}`}
                  onSelect={() => handleSuggestionClick(suggestion)}
                  className="flex items-center gap-2"
                >
                  <MapPin className="text-muted-foreground h-4 w-4" />
                  <div className="flex flex-col">
                    <span>{suggestion.text}</span>
                    {suggestion.entityData.sectorCragName && (
                      <span className="text-muted-foreground text-xs">{suggestion.entityData.sectorCragName}</span>
                    )}
                  </div>
                  {suggestion.entityData.sectorRoutesCount !== null && (
                    <span className="text-muted-foreground ml-auto text-xs">
                      {suggestion.entityData.sectorRoutesCount} routes
                    </span>
                  )}
                </CommandItem>
              ))}
            </CommandGroup>
          )}

          {hasRoutes && (
            <CommandGroup heading="Routes">
              {grouped.route.map((suggestion) => (
                <CommandItem
                  key={`route-${suggestion.id}`}
                  value={`route: ${suggestion.text}`}
                  onSelect={() => handleSuggestionClick(suggestion)}
                  className="flex items-center gap-2"
                >
                  <Route className="text-muted-foreground h-4 w-4" />
                  <div className="flex flex-col">
                    <span>{suggestion.text}</span>
                    {suggestion.entityData.routeSectorName && suggestion.entityData.routeCragName && (
                      <span className="text-muted-foreground text-xs">
                        {suggestion.entityData.routeSectorName}, {suggestion.entityData.routeCragName}
                      </span>
                    )}
                  </div>
                  {suggestion.entityData.routeDifficulty && (
                    <span className="ml-auto text-xs font-medium">
                      {formatClimbingGrade(suggestion.entityData.routeDifficulty)}
                    </span>
                  )}
                </CommandItem>
              ))}
            </CommandGroup>
          )}

          {hasUsers && (
            <CommandGroup heading="Users">
              {grouped.user.map((suggestion) => (
                <CommandItem
                  key={`user-${suggestion.id}`}
                  value={`user: ${suggestion.text}`}
                  onSelect={() => handleSuggestionClick(suggestion)}
                  className="flex items-center gap-2"
                >
                  <User className="text-muted-foreground h-4 w-4" />
                  <span>{suggestion.text}</span>
                </CommandItem>
              ))}
            </CommandGroup>
          )}
        </CommandList>
      </CommandDialog>
    </div>
  );
};

export default HeroInput;
