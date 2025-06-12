import { cn } from "@/lib/utils";
import Link from "next/link";
import HeaderLinks from "./HeaderLinks";
import HeaderSearch from "./HeaderSearch";
import MobileMenu from "./MobileMenu";

import MobileSearch from "./MobileSearch";
import UserProfileNavigation from "./UserProfileNavigation";

const Header = () => {
  return (
    <header
      className={cn("bg-background/80 sticky top-0 z-50 w-full backdrop-blur-md", [
        "border-grid border-b, border-black",
      ])}
    >
      <div className="relative flex h-16 items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
        {/* Left section */}
        <div className="flex items-center">
          {/* Mobile menu - visible on mobile only */}
          <div className="sm:hidden">
            <MobileMenu />
          </div>

          {/* Logo and links - visible on desktop only */}
          <div className="hidden items-center gap-10 sm:flex">
            <Link href="/" className={cn("text-2xl font-bold")}>
              Alpinity
            </Link>
            <HeaderLinks />
          </div>
        </div>

        {/* Right section - on desktop contains search & user profile. On mobile shows the search icon */}
        <div className="flex items-center gap-4">
          {/* Search - visible on desktop only, next to user profile */}
          <div className="hidden sm:block">
            <HeaderSearch />
          </div>

          {/* Search icon - visible on mobile only */}
          <div className="block sm:hidden">
            <MobileSearch />
          </div>

          {/* User profile - hidden on mobile */}
          <div className="hidden sm:block">
            <UserProfileNavigation />
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
