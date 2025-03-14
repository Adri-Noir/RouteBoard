"use client";

import useAuth from "@/lib/hooks/useAuth";
import { LogOut, Settings, User } from "lucide-react";
import dynamic from "next/dynamic";
import Link from "next/link";
import { Avatar, AvatarFallback, AvatarImage } from "../../avatar";
import { Button } from "../../button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "../../dropdown-menu";

const DynamicSmallLoadingSpinner = dynamic(
  () => import("@/lib/helpers/LoadingSpinner").then((mod) => mod.SmallLoadingSpinner),
  {
    ssr: false,
  },
);

const UserProfileNavigation = () => {
  const { isAuthenticated, isUserLoading, logout } = useAuth();

  return (
    <DynamicSmallLoadingSpinner isLoading={isUserLoading}>
      {isAuthenticated ? (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Avatar>
              <AvatarImage src="https://github.com/shadcn.png" />
              <AvatarFallback>CN</AvatarFallback>
            </Avatar>
          </DropdownMenuTrigger>
          <DropdownMenuContent className="z-10000 w-56">
            <DropdownMenuLabel>My Account</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuGroup>
              <DropdownMenuItem>
                <User />
                <span>Profile</span>
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Settings />
                <span>Settings</span>
              </DropdownMenuItem>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuItem onClick={logout}>
              <LogOut />
              <span>Log out</span>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      ) : (
        <Link href="/login">
          <Button>Login</Button>
        </Link>
      )}
    </DynamicSmallLoadingSpinner>
  );
};

export default UserProfileNavigation;
