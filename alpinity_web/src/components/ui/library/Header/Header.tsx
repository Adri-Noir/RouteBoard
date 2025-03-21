import { cn } from "@/lib/utils";
import Link from "next/link";
import HeaderLinks from "./HeaderLinks";
import HeaderSearch from "./HeaderSearch";
import MobileMenu from "./MobileMenu";
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

        {/* Middle section - search centered on mobile only */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 sm:hidden">
          <HeaderSearch />
        </div>

        {/* Right section - on desktop, contains search and user profile */}
        <div className="flex items-center gap-4">
          {/* Search - visible on desktop only, next to user profile */}
          <div className="hidden sm:block">
            <HeaderSearch />
          </div>

          {/* User profile */}
          <UserProfileNavigation />
        </div>
      </div>
    </header>
  );
};

export default Header;
