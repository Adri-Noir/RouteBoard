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
    <div className="w-full max-w-[180px] sm:max-w-[240px] md:max-w-[320px] lg:max-w-[400px]">
      <Search
        triggerClassName="w-full"
        triggerPlaceholder="Search for crags, sectors, routes..."
        showShortcut={false}
      />
    </div>
  );
};

export default HeaderSearch;
