"use client";

import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import UserSelectionForm from "./UserSelectionForm";

interface UserSelectionDialogProps {
  cragId: string;
  isOpen: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess?: () => void;
}

const UserSelectionDialog = ({ cragId, isOpen, onOpenChange, onSuccess }: UserSelectionDialogProps) => {
  const handleSuccess = () => {
    onOpenChange(false);
    onSuccess?.();
  };

  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto" aria-describedby="user-selection-description">
        <DialogHeader>
          <DialogTitle>Manage Crag Users</DialogTitle>
        </DialogHeader>
        <div id="user-selection-description" className="sr-only">
          Select which users should have access to this crag
        </div>
        <UserSelectionForm cragId={cragId} onSuccess={handleSuccess} onCancel={() => onOpenChange(false)} />
      </DialogContent>
    </Dialog>
  );
};

export default UserSelectionDialog;
