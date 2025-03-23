"use client";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { SectorDetailedDto } from "@/lib/api";
import { ChevronDown } from "lucide-react";

interface SectorSelectorProps {
  sectors: SectorDetailedDto[];
  currentSectorId?: string;
  onSectorChange?: (sectorId: string) => void;
  showAllOption?: boolean;
}

const SectorSelector = ({ sectors, currentSectorId, onSectorChange, showAllOption = true }: SectorSelectorProps) => {
  if (!sectors || sectors.length === 0) {
    return null;
  }

  const currentSector = currentSectorId ? sectors.find((sector) => sector.id === currentSectorId) : undefined;

  const displayName = currentSector ? currentSector.name || "Unnamed Sector" : "All Sectors";

  return (
    <DropdownMenu>
      <DropdownMenuTrigger className="hover:text-primary flex items-center gap-1 text-lg font-medium focus:outline-none">
        {displayName}
        <ChevronDown className="h-4 w-4" />
      </DropdownMenuTrigger>
      <DropdownMenuContent align="start">
        {showAllOption && (
          <DropdownMenuItem onClick={() => onSectorChange?.("")} className={!currentSectorId ? "bg-muted" : ""}>
            All Sectors
            {sectors && <span className="ml-2 text-xs opacity-70">({sectors.length} sectors)</span>}
          </DropdownMenuItem>
        )}
        {sectors.map((sector) => (
          <DropdownMenuItem
            key={sector.id}
            onClick={() => onSectorChange?.(sector.id)}
            className={currentSectorId === sector.id ? "bg-muted" : ""}
          >
            {sector.name || "Unnamed Sector"}
            {sector.routes && <span className="ml-2 text-xs opacity-70">({sector.routes.length} routes)</span>}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
};

export default SectorSelector;
