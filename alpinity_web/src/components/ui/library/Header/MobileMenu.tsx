"use client";

/*
  Enhanced mobile navigation drawer.
  - Conditionally renders links/actions based on authentication status.
  - Highlights the active route.
  - Closes the drawer when the user navigates.
*/

import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { Compass, Edit, Home, LogOut, Menu, Plus, Settings, User as UserIcon } from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { type ElementType, useState } from "react";

import CreateCragForm from "@/components/modules/crag/create-crag/CreateCragForm";
import EditProfileDialog from "@/components/modules/profile/edit-profile/EditProfileDialog";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Separator } from "@/components/ui/separator";
import { CragDetailedDto } from "@/lib/api";
import useAuth from "@/lib/hooks/useAuth";
import { cn } from "@/lib/utils";

const MobileMenu = () => {
  const [open, setOpen] = useState(false);
  const [isCragCreationOpen, setIsCragCreationOpen] = useState(false);
  const [isEditProfileOpen, setIsEditProfileOpen] = useState(false);
  const pathname = usePathname();
  const router = useRouter();

  const { isAuthenticated, logout, user } = useAuth();

  // Helper to navigate & close the drawer
  const handleNavigate = (href: string, callback?: () => void) => {
    setOpen(false);
    if (callback) callback();
    router.push(href);
  };

  const handleCragClick = () => {
    setOpen(false);
    setIsCragCreationOpen(true);
  };

  const handleEditProfileClick = () => {
    setOpen(false);
    setIsEditProfileOpen(true);
  };

  const handleCragCreateSuccess = (crag: CragDetailedDto) => {
    setIsCragCreationOpen(false);
    router.push(`/crag/${crag.id}`);
  };

  const handleEditProfileSuccess = () => {
    setIsEditProfileOpen(false);
    // user updated automatically
  };

  const LinkItem = ({ href, icon: Icon, label }: { href: string; icon: ElementType; label: string }) => (
    <button
      onClick={() => handleNavigate(href)}
      className={cn(
        `hover:bg-accent hover:text-accent-foreground flex w-full items-center gap-3 rounded-md px-2 py-2 text-base font-medium
        transition-colors`,
        pathname.endsWith(href) && "bg-accent/40 text-primary",
      )}
    >
      <Icon className="h-5 w-5" />
      {label}
    </button>
  );

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      {/* Trigger */}
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon">
          <Menu className="h-5 w-5" />
          <span className="sr-only">Open menu</span>
        </Button>
      </SheetTrigger>

      {/* Drawer content */}
      <SheetContent side="left" className="flex flex-col justify-between p-0">
        {/* Header */}
        <div>
          <SheetHeader className="px-5 pt-5">
            <SheetTitle>
              <Link href="/" onClick={() => setOpen(false)} className="text-2xl font-bold">
                Alpinity
              </Link>
            </SheetTitle>
          </SheetHeader>

          <nav className="mt-8 flex flex-col gap-1 px-5">
            <LinkItem href="/" icon={Home} label="Home" />

            {isAuthenticated && <LinkItem href="/explore" icon={Compass} label="Explore" />}

            {isAuthenticated && (
              <>
                <Separator className="my-4" />

                <LinkItem href="/profile" icon={UserIcon} label="Profile" />

                <Accordion type="single" collapsible className="w-full">
                  <AccordionItem value="settings">
                    <AccordionTrigger className="px-2 hover:no-underline">
                      <div className="flex items-center gap-3 text-base font-medium">
                        <Settings className="h-5 w-5" />
                        Settings
                      </div>
                    </AccordionTrigger>
                    <AccordionContent className="pr-2 pl-7">
                      {(user?.role === "Admin" || user?.role === "Creator") && (
                        <button
                          onClick={handleCragClick}
                          className="hover:bg-accent hover:text-accent-foreground flex w-full items-center gap-3 rounded-md px-2 py-2 text-sm font-medium
                            transition-colors"
                        >
                          <Plus className="h-4 w-4" />
                          Create Crag
                        </button>
                      )}

                      <button
                        onClick={handleEditProfileClick}
                        className="hover:bg-accent hover:text-accent-foreground flex w-full items-center gap-3 rounded-md px-2 py-2 text-sm font-medium
                          transition-colors"
                      >
                        <Edit className="h-4 w-4" />
                        Edit Profile
                      </button>
                    </AccordionContent>
                  </AccordionItem>
                </Accordion>
              </>
            )}
          </nav>
        </div>

        {/* Footer */}
        <div className="px-5 pb-5">
          {isAuthenticated ? (
            <Button
              variant="outline"
              className="w-full justify-start gap-3"
              onClick={() => {
                logout();
                setOpen(false);
              }}
            >
              <LogOut className="h-4 w-4" /> Log out
            </Button>
          ) : (
            <Button
              className="w-full"
              onClick={() => {
                handleNavigate("/login");
              }}
            >
              Login
            </Button>
          )}
        </div>
      </SheetContent>

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
    </Sheet>
  );
};

export default MobileMenu;
