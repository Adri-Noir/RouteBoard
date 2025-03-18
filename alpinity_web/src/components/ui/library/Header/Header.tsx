import { cn } from "@/lib/utils";
import Link from "next/link";
import HeaderLinks from "./HeaderLinks";
import HeaderSearch from "./HeaderSearch";
import UserProfileNavigation from "./UserProfileNavigation";

const Header = () => {
  return (
    <header
      className={cn("bg-background/80 sticky top-0 z-50 w-full backdrop-blur-md", [
        "border-grid border-b, border-black",
      ])}
    >
      <div className="flex items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
        <div className="flex items-center gap-10">
          <Link href="/" className={cn("text-2xl font-bold")}>
            Alpinity
          </Link>
          <HeaderLinks />
        </div>

        <div className="flex items-center gap-4">
          <HeaderSearch />
          <UserProfileNavigation />
        </div>
      </div>
    </header>
  );
};

export default Header;
