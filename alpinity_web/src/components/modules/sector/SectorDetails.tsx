"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SectorDetailedDto } from "@/lib/api/types.gen";
import SectorGradesChart from "./SectorGradesChart";
import SectorPhotos from "./SectorPhotos";
import SectorRoutes from "./SectorRoutes";

interface SectorDetailsProps {
  sector: SectorDetailedDto;
}

const SectorDetails = ({ sector }: SectorDetailsProps) => {
  return (
    <div className="space-y-8">
      {/* Only show basic sector info, no header since we're inside the crag page */}
      {sector.description && <p className="text-muted-foreground text-lg">{sector.description}</p>}

      {/* Grade Distribution Chart */}
      {sector.routes && sector.routes.length > 0 && <SectorGradesChart sector={sector} />}

      {/* Photos section */}
      {sector.photos && sector.photos.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Sector Photos</CardTitle>
          </CardHeader>
          <CardContent>
            <SectorPhotos photos={sector.photos} />
          </CardContent>
        </Card>
      )}

      {/* Routes section now in separate component */}
      <SectorRoutes sector={sector} />
    </div>
  );
};

export default SectorDetails;
