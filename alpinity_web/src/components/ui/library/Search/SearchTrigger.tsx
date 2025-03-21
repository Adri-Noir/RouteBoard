"use client";

import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { ComponentPropsWithoutRef, ReactNode } from "react";

interface SearchTriggerProps extends ComponentPropsWithoutRef<typeof Button> {
  onClick: () => void;
  placeholder?: string;
  children?: ReactNode;
  showShortcut?: boolean;
}

export const SearchTrigger = ({
  onClick,
  placeholder = "Search...",
  className,
  children,
  showShortcut = true,
  ...props
}: SearchTriggerProps) => {
  return (
    <Button
      onClick={onClick}
      variant="outline"
      className={cn("w-full justify-between px-4 py-6 text-left", className)}
      {...props}
    >
      <span className="block truncate sm:inline-block">{children ?? placeholder}</span>
      {showShortcut && (
        <kbd
          className="bg-muted text-muted-foreground pointer-events-none inline-flex h-5 items-center gap-1 rounded border px-1.5 font-mono
            text-[10px] font-medium select-none"
        >
          <span className="text-xs">⌘</span>K
        </kbd>
      )}
    </Button>
  );
};

export default SearchTrigger;
