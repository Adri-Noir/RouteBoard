"use client";

import { PointDto } from "@/lib/api/types.gen";
import { MapPin } from "lucide-react";

interface SectorLocationProps {
  location: PointDto;
}

const SectorLocation = ({ location }: SectorLocationProps) => {
  return (
    <div className="space-y-4">
      <div className="text-muted-foreground flex items-center gap-2">
        <MapPin className="h-4 w-4" />
        <span>
          {location.latitude.toFixed(5)}, {location.longitude.toFixed(5)}
        </span>
      </div>

      <div className="bg-muted aspect-video overflow-hidden rounded-md border">
        {/* If you have a mapping library integration, you can add it here */}
        <div className="text-muted-foreground flex h-full w-full items-center justify-center">
          Map will be displayed here
        </div>
      </div>
    </div>
  );
};

export default SectorLocation;
