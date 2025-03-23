"use client";

import { CommandItem } from "@/components/ui/command";
import { SearchResultDto } from "@/lib/api/types.gen";
import { cn } from "@/lib/utils";
import { Clock, MapPin, Route, User } from "lucide-react";
import Link from "next/link";
import { ReactNode } from "react";
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
      return `/user/${profileUserId}`;
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

  const icon = isRecent ? <Clock className="text-muted-foreground h-4 w-4" /> : getIconForType(type);

  return (
    <LinkWrapper href={href} onClick={onClick}>
      <CommandItem value={`${type}_${text}`} className={cn("flex items-center gap-2", className)}>
        {icon}
        <div className="flex flex-col">
          <span>{text}</span>
          {isRecent && <span className="text-muted-foreground text-xs capitalize">{type}</span>}
          {!isRecent && formattedData.parentName && (
            <span className="text-muted-foreground text-xs">{formattedData.parentName}</span>
          )}
        </div>

        {/* Metadata for different entity types */}
        {formattedData.count !== undefined && formattedData.countLabel && (
          <span className="text-muted-foreground ml-auto text-xs">
            {formattedData.count} {formattedData.countLabel}
          </span>
        )}

        {formattedData.difficulty && <span className="ml-auto text-xs font-medium">{formattedData.difficulty}</span>}
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
