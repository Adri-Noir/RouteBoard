"use client";

import { CommandItem } from "@/components/ui/command";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { SearchResultDto } from "@/lib/api/types.gen";
import { cn } from "@/lib/utils";
import { Clock, MapPin, Route, User } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ReactNode } from "react";
import { getFormattedEntityData, mapEntityTypeToUiType } from "./utils";

interface SearchSuggestionItemProps {
  suggestion: SearchResultDto;
  isRecent?: boolean;
  className?: string;
  onClick?: () => void;
}

const getHref = (suggestion: SearchResultDto) => {
  const { entityType, cragId, sectorId, routeId, profileUserId, routeCragId, routeSectorId } = suggestion;
  const type = entityType ? mapEntityTypeToUiType(entityType) : "crag";

  switch (type) {
    case "crag":
      return `/crag/${cragId}`;
    case "sector":
      return `/crag/${cragId}?sectorId=${sectorId}`;
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
  const { entityType, cragName, sectorName, routeName, profileUsername } = suggestion;
  const type = entityType ? mapEntityTypeToUiType(entityType) : "crag";
  const router = useRouter();

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

  const handleSelect = () => {
    onClick?.();
    if (href !== "#") {
      router.push(href);
    }
  };

  return (
    <LinkWrapper href={href} onClick={onClick}>
      <CommandItem
        value={`${type}_${text}`}
        className={cn("flex items-center gap-3", className)}
        onSelect={handleSelect}
      >
        {/* Image or Icon Container */}
        <div className="relative h-12 w-12 flex-shrink-0">
          {imageUrl ? (
            <ImageWithLoading
              src={imageUrl}
              alt={`${text || type} image`}
              fill
              className="h-full w-full rounded-full object-cover"
              containerClassName="w-full h-full rounded-full bg-muted"
              loadingSize="tiny"
            />
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
