"use client";

import { useState } from "react";
import { SearchDialog } from "./SearchDialog";
import { SearchTrigger } from "./SearchTrigger";

export interface SearchProps {
  triggerPlaceholder?: string;
  dialogPlaceholder?: string;
  triggerClassName?: string;
  showShortcut?: boolean;
}

export const Search = ({
  triggerPlaceholder = "Search for crags, sectors, routes or users...",
  dialogPlaceholder,
  triggerClassName,
  showShortcut = true,
}: SearchProps) => {
  const [open, setOpen] = useState(false);

  return (
    <>
      <SearchTrigger
        onClick={() => setOpen(true)}
        placeholder={triggerPlaceholder}
        className={triggerClassName}
        showShortcut={showShortcut}
      />
      <SearchDialog open={open} onOpenChange={setOpen} inputPlaceholder={dialogPlaceholder || triggerPlaceholder} />
    </>
  );
};

export default Search;
