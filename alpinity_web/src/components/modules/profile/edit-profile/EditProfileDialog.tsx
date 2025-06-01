"use client";

import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import type { UserProfileDto } from "@/lib/api/types.gen";
import EditProfileForm from "./EditProfileForm";

interface EditProfileDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess?: (user: UserProfileDto) => void;
}

const EditProfileDialog = ({ open, onOpenChange, onSuccess }: EditProfileDialogProps) => {
  const handleSuccess = (user?: UserProfileDto) => {
    onOpenChange(false);
    if (user) {
      onSuccess?.(user);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto" aria-describedby="edit-profile-description">
        <DialogHeader>
          <DialogTitle>Edit Profile</DialogTitle>
        </DialogHeader>
        <EditProfileForm onSuccess={handleSuccess} />
      </DialogContent>
    </Dialog>
  );
};

export default EditProfileDialog;
