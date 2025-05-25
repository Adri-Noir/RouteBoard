"use client";

import { CommandItem } from "@/components/ui/command";
import { SearchResultDto } from "@/lib/api/types.gen";
import { cn } from "@/lib/utils";
import { Clock, MapPin, Route, User } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { ReactNode, useState } from "react";
import { getFormattedEntityData, mapEntityTypeToUiType } from "./utils";

interface SearchSuggestionItemProps {
  suggestion: SearchResultDto;
  isRecent?: boolean;
  className?: string;
  onClick?: () => void;
}

const getHref = (suggestion: SearchResultDto) => {
  const { entityType, cragId, sectorId, routeId, profileUserId, sectorCragId, routeCragId, routeSectorId } = suggestion;
  const type = entityType ? mapEntityTypeToUiType(entityType) : "crag";

  switch (type) {
    case "crag":
      return `/crag/${cragId}`;
    case "sector":
      return `/crag/${sectorCragId}?sectorId=${sectorId}`;
    case "route":
      return `/crag/${routeCragId}?sectorId=${routeSectorId}&routeId=${routeId}`;
    case "user":
      return `/profile/${profileUserId}`;
    default:
      return "#";
  }
};

const LinkWrapper = ({ href, children, onClick }: { href: string; children: ReactNode; onClick?: () => void }) => {
  if (href === "#") {
    return children;
  }

  return (
    <Link href={href} onClick={onClick}>
      {children}
    </Link>
  );
};

export const SearchSuggestionItem = ({
  suggestion,
  isRecent = false,
  className,
  onClick,
}: SearchSuggestionItemProps) => {
  const [isLoading, setIsLoading] = useState(true);
  const { entityType, cragName, sectorName, routeName, profileUsername } = suggestion;
  const type = entityType ? mapEntityTypeToUiType(entityType) : "crag";

  // Determine the display text based on entity type
  const text =
    type === "crag"
      ? cragName
      : type === "sector"
        ? sectorName
        : type === "route"
          ? routeName
          : type === "user"
            ? profileUsername
            : "";

  const formattedData = getFormattedEntityData(suggestion);
  const href = getHref(suggestion);
  const imageUrl = suggestion.photo?.url;
  const icon = isRecent ? <Clock className="text-muted-foreground h-4 w-4" /> : getIconForType(type);

  return (
    <LinkWrapper href={href} onClick={onClick}>
      <CommandItem value={`${type}_${text}`} className={cn("flex items-center gap-3", className)}>
        {/* Image or Icon Container */}
        <div className="relative h-8 w-8 flex-shrink-0">
          {imageUrl ? (
            <>
              {/* Loading Skeleton */}
              {isLoading && (
                <div className="bg-muted absolute inset-0 flex items-center justify-center rounded-full">
                  <div className="bg-muted-foreground/20 h-4 w-4 animate-pulse rounded-full"></div>
                </div>
              )}
              {/* Actual Image */}
              <Image
                src={imageUrl}
                alt={`${text || type} image`}
                width={32}
                height={32}
                className={cn(
                  "h-full w-full rounded-full object-cover",
                  isLoading ? "opacity-0" : "opacity-100 transition-opacity duration-300", // Fade in
                )}
                onLoad={() => setIsLoading(false)}
                onError={() => setIsLoading(false)} // Handle potential image loading errors
              />
            </>
          ) : (
            // Fallback Icon
            <div className="bg-muted flex h-full w-full items-center justify-center rounded-full">{icon}</div>
          )}
        </div>

        {/* Text Content */}
        <div className="flex flex-col overflow-hidden">
          <span className="truncate font-medium">{text}</span>
          {isRecent && <span className="text-muted-foreground truncate text-xs capitalize">{type}</span>}
          {!isRecent && formattedData.parentName && (
            <span className="text-muted-foreground truncate text-xs">{formattedData.parentName}</span>
          )}
        </div>

        {/* Metadata */}
        <div className="ml-auto flex flex-shrink-0 items-center gap-2">
          {formattedData.count !== undefined && formattedData.countLabel && (
            <span className="text-muted-foreground text-xs">
              {formattedData.count} {formattedData.countLabel}
            </span>
          )}
          {formattedData.difficulty && <span className="text-xs font-medium">{formattedData.difficulty}</span>}
        </div>
      </CommandItem>
    </LinkWrapper>
  );
};

function getIconForType(type: string): ReactNode {
  switch (type) {
    case "crag":
    case "sector":
      return <MapPin className="text-muted-foreground h-4 w-4" />;
    case "route":
      return <Route className="text-muted-foreground h-4 w-4" />;
    case "user":
      return <User className="text-muted-foreground h-4 w-4" />;
    default:
      return null;
  }
}
