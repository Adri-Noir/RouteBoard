"use client";

import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { CragSectorDto } from "@/lib/api/types.gen";

interface SectorSelectorProps {
  sectors: CragSectorDto[];
  currentSectorId?: string;
  onSectorChange?: (sectorId: string) => void;
}

const SectorSelector = ({ sectors, currentSectorId, onSectorChange }: SectorSelectorProps) => {
  const handleSectorChange = (sectorId: string) => {
    if (onSectorChange) {
      onSectorChange(sectorId);
    }
  };

  if (!sectors || sectors.length === 0) {
    return null;
  }

  return (
    <div className="flex items-center gap-2">
      <span className="text-sm font-medium">Sector:</span>
      <Select value={currentSectorId} onValueChange={handleSectorChange}>
        <SelectTrigger className="w-[200px]">
          <SelectValue placeholder="Select a sector" />
        </SelectTrigger>
        <SelectContent>
          {sectors.map((sector) => (
            <SelectItem key={sector.id} value={sector.id}>
              {sector.name || "Unnamed Sector"}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
};

export default SectorSelector;
