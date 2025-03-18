"use client";

import { CommandItem } from "@/components/ui/command";
import { cn } from "@/lib/utils";
import { Clock, MapPin, Route, User } from "lucide-react";
import Link from "next/link";
import { ReactNode } from "react";
import { SearchSuggestion } from "./types";
import { getFormattedEntityData } from "./utils";

interface SearchSuggestionItemProps {
  suggestion: SearchSuggestion;
  isRecent?: boolean;
  className?: string;
}

export const SearchSuggestionItem = ({ suggestion, isRecent = false, className }: SearchSuggestionItemProps) => {
  const { text, type, id } = suggestion;
  const formattedData = getFormattedEntityData(suggestion);
  const prefix = isRecent ? "recent: " : `${type}: `;

  // Handle links differently based on type
  const href = type === "crag" ? `/crag/${id}` : "#"; // Customize other links as needed

  const icon = isRecent ? <Clock className="text-muted-foreground h-4 w-4" /> : getIconForType(type);

  const content = (
    <CommandItem value={`${prefix}${text}`} className={cn("flex items-center gap-2", className)}>
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
  );

  // For clickable items that navigate to a specific URL
  if (href !== "#") {
    return <Link href={href}>{content}</Link>;
  }

  return content;
};

function getIconForType(type: SearchSuggestion["type"]): ReactNode {
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
