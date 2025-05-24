"use client";

import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { SectorRouteDto } from "@/lib/api/types.gen";
import LogAscentForm from "./LogAscentForm";

interface LogAscentDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  route: SectorRouteDto | null;
}

const LogAscentDialog = ({ open, onOpenChange, route }: LogAscentDialogProps) => {
  const handleSuccess = () => {
    onOpenChange(false);
  };

  const handleCancel = () => {
    onOpenChange(false);
  };

  if (!route) {
    return null;
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] max-w-3xl overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Log Ascent</DialogTitle>
          <DialogDescription>Recording ascent for {route.name || "Unnamed Route"}</DialogDescription>
        </DialogHeader>
        <LogAscentForm route={route} onSuccess={handleSuccess} onCancel={handleCancel} />
      </DialogContent>
    </Dialog>
  );
};

export default LogAscentDialog;
