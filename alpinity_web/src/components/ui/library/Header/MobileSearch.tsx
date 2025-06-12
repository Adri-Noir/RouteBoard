"use client";

import { Button } from "@/components/ui/button";
import useAuth from "@/lib/hooks/useAuth";
import { Search as SearchIcon } from "lucide-react";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { SearchDialog } from "../Search/SearchDialog";

/**
 * MobileSearch shows a single icon button that opens the search dialog.
 * It is meant to be used only on small screens.
 */
const MobileSearch = () => {
  const { isAuthenticated } = useAuth();
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  const isHomePage = pathname === "/";

  if (isHomePage || !isAuthenticated) {
    return null;
  }

  return (
    <>
      <Button size="icon" variant="ghost" aria-label="Open search" onClick={() => setOpen(true)}>
        <SearchIcon className="size-5" />
      </Button>
      <SearchDialog open={open} onOpenChange={setOpen} />
    </>
  );
};

export default MobileSearch;
