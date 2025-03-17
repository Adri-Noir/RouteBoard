"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { postApiSearchOptions } from "@/lib/api/@tanstack/react-query.gen";
import { SearchResultDto, SearchResultItemType } from "@/lib/api/types.gen";
import useAuth from "@/lib/hooks/useAuth";
import { cn, debounce, formatClimbingGrade } from "@/lib/utils";
import { useQuery } from "@tanstack/react-query";
import { MapPin, Route, User } from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";

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
  const [searchQuery, setSearchQuery] = useState("");
  const [debouncedQuery, setDebouncedQuery] = useState("");
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
  const [activeIndex, setActiveIndex] = useState(-1);
  const inputRef = useRef<HTMLInputElement>(null);
  const suggestionsRef = useRef<HTMLDivElement>(null);

  // Skip the query if the search query is empty
  const shouldFetch = debouncedQuery.trim().length > 0;

  const { data: searchData, isLoading: isLoadingSearch } = useQuery({
    ...postApiSearchOptions({
      body: {
        query: debouncedQuery,
      },
    }),
    enabled: shouldFetch,
  });

  // Create debounced search handler
  const debouncedSetQuery = useCallback(
    debounce((value: string) => {
      setDebouncedQuery(value);
    }, 300),
    [],
  );

  // Handle input change with debounce
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSearchQuery(value);
    debouncedSetQuery(value);
  };

  // Update suggestions based on API response
  useEffect(() => {
    if (!shouldFetch) {
      setSuggestions([]);
      return;
    }

    if (searchData) {
      const mappedSuggestions = searchData.map(mapSearchResultToSuggestion);
      setSuggestions(mappedSuggestions);
      setShowSuggestions(mappedSuggestions.length > 0);
      setActiveIndex(-1); // Reset active index when suggestions change
    }
  }, [searchData, shouldFetch]);

  // Handle keyboard navigation
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (!showSuggestions || suggestions.length === 0) return;

    // Arrow down
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setActiveIndex((prevIndex) => (prevIndex < suggestions.length - 1 ? prevIndex + 1 : 0));
    }
    // Arrow up
    else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActiveIndex((prevIndex) => (prevIndex > 0 ? prevIndex - 1 : suggestions.length - 1));
    }
    // Enter
    else if (e.key === "Enter" && activeIndex >= 0) {
      e.preventDefault();
      handleSuggestionClick(suggestions[activeIndex]);
    }
    // Escape
    else if (e.key === "Escape") {
      setShowSuggestions(false);
    }
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Searching for:", searchQuery);
    setShowSuggestions(false);
    // Implement search functionality here
  };

  const handleSuggestionClick = (suggestion: Suggestion) => {
    setSearchQuery(suggestion.text);
    setDebouncedQuery(suggestion.text);
    setShowSuggestions(false);
    // Optionally trigger search immediately
    console.log("Selected suggestion:", suggestion);
  };

  // Group suggestions by type
  const groupedSuggestions = () => {
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
  };

  if (!isAuthenticated) {
    return null;
  }

  const grouped = groupedSuggestions();
  const hasCrags = grouped.crag.length > 0;
  const hasSectors = grouped.sector.length > 0;
  const hasRoutes = grouped.route.length > 0;
  const hasUsers = grouped.user.length > 0;

  return (
    <div className="mt-10 w-full max-w-lg">
      <form onSubmit={handleSearch} className="flex w-full flex-col items-center gap-2 sm:flex-row">
        <div className="relative w-full">
          <Input
            ref={inputRef}
            type="text"
            value={searchQuery}
            onChange={handleInputChange}
            placeholder="Search for crags, sectors, routes or users..."
            className="rounded-md bg-white/95 px-4 py-6"
            onBlur={() => {
              setShowSuggestions(false);
            }}
            onFocus={() => {
              if (searchQuery.trim() !== "" && suggestions.length > 0) {
                setShowSuggestions(true);
              }
            }}
            onKeyDown={handleKeyDown}
          />

          {/* Loading indicator */}
          {isLoadingSearch && debouncedQuery.trim() !== "" && (
            <div className="absolute top-1/2 right-3 -translate-y-1/2">
              <div className="border-primary h-4 w-4 animate-spin rounded-full border-2 border-t-transparent"></div>
            </div>
          )}

          {/* Suggestions dropdown */}
          {showSuggestions && (
            <div
              ref={suggestionsRef}
              className="bg-popover border-input absolute z-50 mt-1 max-h-60 w-full overflow-auto rounded-md border shadow-md"
            >
              {suggestions.length > 0 ? (
                <>
                  {/* Crags */}
                  {hasCrags && (
                    <div className="py-1">
                      <div className="text-muted-foreground px-4 py-1 text-xs font-medium">Crags</div>
                      {grouped.crag.map((suggestion, index) => {
                        const globalIndex = suggestions.findIndex(
                          (s) => s.id === suggestion.id && s.type === suggestion.type,
                        );
                        return (
                          <div
                            key={`crag-${suggestion.id}`}
                            className={cn(
                              "flex cursor-pointer items-center gap-2 px-4 py-2 text-sm transition-colors",
                              globalIndex === activeIndex
                                ? "bg-accent text-accent-foreground"
                                : "hover:bg-accent hover:text-accent-foreground",
                            )}
                            onClick={() => handleSuggestionClick(suggestion)}
                            onMouseEnter={() => setActiveIndex(globalIndex)}
                          >
                            <MapPin className="text-muted-foreground h-4 w-4" />
                            <span>{suggestion.text}</span>
                            {suggestion.entityData.cragRoutesCount !== null && (
                              <span className="text-muted-foreground ml-auto text-xs">
                                {suggestion.entityData.cragRoutesCount} routes
                              </span>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  )}

                  {/* Sectors */}
                  {hasSectors && (
                    <div className="border-input border-t py-1">
                      <div className="text-muted-foreground px-4 py-1 text-xs font-medium">Sectors</div>
                      {grouped.sector.map((suggestion, index) => {
                        const globalIndex = suggestions.findIndex(
                          (s) => s.id === suggestion.id && s.type === suggestion.type,
                        );
                        return (
                          <div
                            key={`sector-${suggestion.id}`}
                            className={cn(
                              "flex cursor-pointer items-center gap-2 px-4 py-2 text-sm transition-colors",
                              globalIndex === activeIndex
                                ? "bg-accent text-accent-foreground"
                                : "hover:bg-accent hover:text-accent-foreground",
                            )}
                            onClick={() => handleSuggestionClick(suggestion)}
                            onMouseEnter={() => setActiveIndex(globalIndex)}
                          >
                            <MapPin className="text-muted-foreground h-4 w-4" />
                            <div className="flex flex-col">
                              <span>{suggestion.text}</span>
                              {suggestion.entityData.sectorCragName && (
                                <span className="text-muted-foreground text-xs">
                                  {suggestion.entityData.sectorCragName}
                                </span>
                              )}
                            </div>
                            {suggestion.entityData.sectorRoutesCount !== null && (
                              <span className="text-muted-foreground ml-auto text-xs">
                                {suggestion.entityData.sectorRoutesCount} routes
                              </span>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  )}

                  {/* Routes */}
                  {hasRoutes && (
                    <div className="border-input border-t py-1">
                      <div className="text-muted-foreground px-4 py-1 text-xs font-medium">Routes</div>
                      {grouped.route.map((suggestion, index) => {
                        const globalIndex = suggestions.findIndex(
                          (s) => s.id === suggestion.id && s.type === suggestion.type,
                        );
                        return (
                          <div
                            key={`route-${suggestion.id}`}
                            className={cn(
                              "flex cursor-pointer items-center gap-2 px-4 py-2 text-sm transition-colors",
                              globalIndex === activeIndex
                                ? "bg-accent text-accent-foreground"
                                : "hover:bg-accent hover:text-accent-foreground",
                            )}
                            onClick={() => handleSuggestionClick(suggestion)}
                            onMouseEnter={() => setActiveIndex(globalIndex)}
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
                          </div>
                        );
                      })}
                    </div>
                  )}

                  {/* Users */}
                  {hasUsers && (
                    <div className="border-input border-t py-1">
                      <div className="text-muted-foreground px-4 py-1 text-xs font-medium">Users</div>
                      {grouped.user.map((suggestion, index) => {
                        const globalIndex = suggestions.findIndex(
                          (s) => s.id === suggestion.id && s.type === suggestion.type,
                        );
                        return (
                          <div
                            key={`user-${suggestion.id}`}
                            className={cn(
                              "flex cursor-pointer items-center gap-2 px-4 py-2 text-sm transition-colors",
                              globalIndex === activeIndex
                                ? "bg-accent text-accent-foreground"
                                : "hover:bg-accent hover:text-accent-foreground",
                            )}
                            onClick={() => handleSuggestionClick(suggestion)}
                            onMouseEnter={() => setActiveIndex(globalIndex)}
                          >
                            <User className="text-muted-foreground h-4 w-4" />
                            <span>{suggestion.text}</span>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </>
              ) : (
                <div className="text-muted-foreground px-4 py-3 text-center text-sm">No results found</div>
              )}
            </div>
          )}
        </div>
        <Button type="submit" className="px-6 py-6">
          Search
        </Button>
      </form>
    </div>
  );
};

export default HeroInput;
