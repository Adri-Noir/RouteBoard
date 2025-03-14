import { cn } from "@/lib/utils";
import Link from "next/link";
import UserProfileNavigation from "./UserProfileNavigation";

const Header = () => {
  return (
    <header
      className={cn("fixed top-0 z-50 w-full transition-all duration-300 ease-in-out", [
        "border-grid border-b",
        "bg-background/50 backdrop-blur-sm",
      ])}
    >
      <div className="mx-4 flex items-center justify-between py-4 sm:px-6 lg:px-8">
        <Link href="/" className={cn("text-2xl font-bold text-black")}>
          Alpinity
        </Link>

        <UserProfileNavigation />
      </div>
    </header>
  );
};

export default Header;
