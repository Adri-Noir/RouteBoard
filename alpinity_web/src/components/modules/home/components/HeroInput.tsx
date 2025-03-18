"use client";

import { Search } from "@/components/ui/library/Search";
import useAuth from "@/lib/hooks/useAuth";

const HeroInput = () => {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="mt-10 w-full max-w-lg">
      <Search
        triggerPlaceholder="Search for crags, sectors, routes or users..."
        dialogPlaceholder="Search for crags, sectors, routes or users..."
      />
    </div>
  );
};

export default HeroInput;
