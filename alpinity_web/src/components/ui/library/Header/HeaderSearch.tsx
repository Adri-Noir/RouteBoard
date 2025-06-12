"use client";
import useAuth from "@/lib/hooks/useAuth";
import { usePathname } from "next/navigation";
import { Search } from "../Search";

const HeaderSearch = () => {
  const pathname = usePathname();
  const { isAuthenticated } = useAuth();

  const isHomePage = pathname === "/";

  if (isHomePage || !isAuthenticated) {
    return null;
  }

  return (
    <div className="w-full max-w-[200px] sm:max-w-[240px] md:max-w-[320px] lg:max-w-[400px]">
      <Search triggerClassName="w-full" triggerPlaceholder="Search for crags, sectors, routes..." />
    </div>
  );
};

export default HeaderSearch;
