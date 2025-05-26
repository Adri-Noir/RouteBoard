"use client";

import CreateCragForm from "@/components/modules/crag/create-crag/CreateCragForm";
import EditProfileDialog from "@/components/modules/profile/edit-profile/EditProfileDialog";
import { CragDetailedDto } from "@/lib/api";
import useAuth from "@/lib/hooks/useAuth";
import { Edit, LogOut, Plus, Settings, User } from "lucide-react";
import dynamic from "next/dynamic";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState } from "react";
import { Avatar, AvatarFallback, AvatarImage } from "../../avatar";
import { Button } from "../../button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "../../dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuPortal,
  DropdownMenuSeparator,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
  DropdownMenuTrigger,
} from "../../dropdown-menu";

const DynamicSmallLoadingSpinner = dynamic(
  () => import("@/lib/helpers/LoadingSpinner").then((mod) => mod.SmallLoadingSpinner),
  {
    ssr: false,
  },
);

const UserProfileNavigation = () => {
  const pathname = usePathname();
  const router = useRouter();
  const [isCragCreationOpen, setIsCragCreationOpen] = useState(false);
  const [isEditProfileOpen, setIsEditProfileOpen] = useState(false);

  const { user, isAuthenticated, isUserLoading, logout } = useAuth();

  const onProfileClick = () => {
    router.push("/profile");
  };

  const onCreateCragClick = () => {
    setIsCragCreationOpen(true);
  };

  const onEditProfileClick = () => {
    setIsEditProfileOpen(true);
  };

  const handleCragCreateSuccess = (crag: CragDetailedDto) => {
    setIsCragCreationOpen(false);
    router.push(`/crag/${crag.id}`);
  };

  const handleEditProfileSuccess = () => {
    setIsEditProfileOpen(false);
    // The user data will be automatically updated through the query invalidation
  };

  return (
    <>
      <DynamicSmallLoadingSpinner isLoading={isUserLoading}>
        {isAuthenticated ? (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Avatar>
                <AvatarImage src={user?.profilePhoto?.url ?? undefined} />
                <AvatarFallback>{user?.profilePhoto?.url ? "A" : user?.username?.charAt(0)}</AvatarFallback>
              </Avatar>
            </DropdownMenuTrigger>
            <DropdownMenuContent className="z-10000 w-56">
              <DropdownMenuLabel>My Account</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuGroup>
                <DropdownMenuItem onClick={onProfileClick}>
                  <User size={16} />
                  <span>Profile</span>
                </DropdownMenuItem>
                <DropdownMenuItem onClick={onEditProfileClick}>
                  <Edit size={16} />
                  <span>Edit Profile</span>
                </DropdownMenuItem>
                {(user?.role === "Admin" || user?.role === "Creator") && (
                  <DropdownMenuSub>
                    <DropdownMenuSubTrigger>
                      <Settings size={16} className="mr-2" />
                      <span>Settings</span>
                    </DropdownMenuSubTrigger>
                    <DropdownMenuPortal>
                      <DropdownMenuSubContent>
                        <DropdownMenuItem onClick={onCreateCragClick}>
                          <Plus size={16} />
                          <span>Create Crag</span>
                        </DropdownMenuItem>
                      </DropdownMenuSubContent>
                    </DropdownMenuPortal>
                  </DropdownMenuSub>
                )}
              </DropdownMenuGroup>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={logout}>
                <LogOut size={16} />
                <span>Log out</span>
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        ) : (
          <>
            {pathname !== "/login" && (
              <Link href="/login">
                <Button>Login</Button>
              </Link>
            )}
          </>
        )}
      </DynamicSmallLoadingSpinner>

      {/* Create Crag Dialog */}
      <Dialog open={isCragCreationOpen} onOpenChange={setIsCragCreationOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="create-crag-description">
          <DialogHeader>
            <DialogTitle>Create New Crag</DialogTitle>
          </DialogHeader>
          <CreateCragForm onSuccess={handleCragCreateSuccess} />
        </DialogContent>
      </Dialog>

      {/* Edit Profile Dialog */}
      <EditProfileDialog
        open={isEditProfileOpen}
        onOpenChange={setIsEditProfileOpen}
        onSuccess={handleEditProfileSuccess}
      />
    </>
  );
};

export default UserProfileNavigation;
