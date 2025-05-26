"use client";

import { Button } from "@/components/ui/button";
import { Users } from "lucide-react";
import { useState } from "react";
import UserSelectionDialog from "./UserSelectionDialog";

interface UserSelectionTriggerProps {
  cragId: string;
  onSuccess?: () => void;
  variant?: "default" | "outline" | "secondary" | "ghost" | "link" | "destructive";
  size?: "default" | "sm" | "lg" | "icon";
  className?: string;
  children?: React.ReactNode;
}

const UserSelectionTrigger = ({
  cragId,
  onSuccess,
  variant = "outline",
  size = "default",
  className,
  children,
}: UserSelectionTriggerProps) => {
  const [isDialogOpen, setIsDialogOpen] = useState(false);

  const handleSuccess = () => {
    onSuccess?.();
  };

  return (
    <>
      <Button variant={variant} size={size} className={className} onClick={() => setIsDialogOpen(true)}>
        {children || (
          <>
            <Users className="mr-2 h-4 w-4" />
            Manage Users
          </>
        )}
      </Button>

      <UserSelectionDialog
        cragId={cragId}
        isOpen={isDialogOpen}
        onOpenChange={setIsDialogOpen}
        onSuccess={handleSuccess}
      />
    </>
  );
};

export default UserSelectionTrigger;
