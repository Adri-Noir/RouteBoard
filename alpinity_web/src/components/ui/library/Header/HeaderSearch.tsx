"use client";
import { usePathname } from "next/navigation";
import { Search } from "../Search";

const HeaderSearch = () => {
  const pathname = usePathname();

  const isHomePage = pathname === "/";

  if (isHomePage) {
    return null;
  }

  return (
    <div className="flex items-center gap-2">
      <Search />
    </div>
  );
};

export default HeaderSearch;
