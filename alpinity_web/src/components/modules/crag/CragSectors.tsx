"use client";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { CragSectorDto } from "@/lib/api/types.gen";
import { ChevronRight, MapPin } from "lucide-react";

interface CragSectorsProps {
  sectors: CragSectorDto[];
  onSectorClick?: (sectorId: string) => void;
}

const CragSectors = ({ sectors, onSectorClick }: CragSectorsProps) => {
  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
      {sectors.map((sector) => (
        <Card key={sector.id}>
          <CardHeader>
            <CardTitle>{sector.name || "Unnamed Sector"}</CardTitle>
            {sector.routesCount !== undefined && (
              <CardDescription>
                {sector.routesCount} {sector.routesCount === 1 ? "route" : "routes"}
              </CardDescription>
            )}
          </CardHeader>
          {sector.description && (
            <CardContent>
              <p className="text-muted-foreground line-clamp-2 text-sm">{sector.description}</p>
            </CardContent>
          )}
          <CardFooter className="flex justify-between">
            {sector.location && (
              <div className="text-muted-foreground flex items-center gap-1 text-sm">
                <MapPin className="h-3 w-3" />
                <span>
                  {sector.location.latitude.toFixed(5)}, {sector.location.longitude.toFixed(5)}
                </span>
              </div>
            )}
            <Button size="sm" variant="outline" onClick={() => onSectorClick?.(sector.id)}>
              View Sector
              <ChevronRight className="ml-1 h-4 w-4" />
            </Button>
          </CardFooter>
        </Card>
      ))}
    </div>
  );
};

export default CragSectors;
