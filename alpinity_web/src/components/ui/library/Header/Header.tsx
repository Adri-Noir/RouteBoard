import { cn } from "@/lib/utils";
import Link from "next/link";
import HeaderLinks from "./HeaderLinks";
import UserProfileNavigation from "./UserProfileNavigation";

const Header = () => {
  return (
    <header
      className={cn("bg-background/80 sticky top-0 z-50 w-full backdrop-blur-md", [
        "border-grid border-b, border-black",
      ])}
    >
      <div className="mx-4 flex items-center justify-between py-4 sm:px-6 lg:px-8">
        <div className="flex items-center gap-10">
          <Link href="/" className={cn("text-2xl font-bold")}>
            Alpinity
          </Link>
          <HeaderLinks />
        </div>

        <UserProfileNavigation />
      </div>
    </header>
  );
};

export default Header;
