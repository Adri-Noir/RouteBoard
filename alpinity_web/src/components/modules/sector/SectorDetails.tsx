"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SectorDetailedDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { useState } from "react";
import SectorGradesChart from "./SectorGradesChart";
import SectorPhotos from "./SectorPhotos";
import SectorRoutes from "./SectorRoutes";

interface SectorDetailsProps {
  sector: SectorDetailedDto;
}

const SectorDetails = ({ sector }: SectorDetailsProps) => {
  const [selectedGrade, setSelectedGrade] = useState<string | null>(null);

  // Filter routes by the selected grade
  const filteredRoutes = selectedGrade
    ? sector.routes?.filter((route) => {
        if (!route.grade) return false;
        return formatClimbingGrade(route.grade) === selectedGrade;
      })
    : sector.routes;

  // Create a filtered sector object to pass to the routes component
  const filteredSector = selectedGrade
    ? {
        ...sector,
        routes: filteredRoutes,
      }
    : sector;

  const handleGradeFilterChange = (grade: string | null) => {
    setSelectedGrade(grade);
  };

  return (
    <div className="space-y-8">
      {/* Only show basic sector info, no header since we're inside the crag page */}
      {sector.description && <p className="text-muted-foreground text-lg">{sector.description}</p>}

      {/* Grade Distribution Chart */}
      {sector.routes && sector.routes.length > 0 && (
        <SectorGradesChart sector={sector} onFilterChange={handleGradeFilterChange} />
      )}

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

      {/* Routes section with filtered routes */}
      {filteredRoutes && filteredRoutes.length > 0 ? (
        <SectorRoutes sector={filteredSector} />
      ) : (
        selectedGrade && (
          <Card>
            <CardContent className="p-6 text-center">
              <p className="text-muted-foreground">No routes found with grade {selectedGrade}.</p>
            </CardContent>
          </Card>
        )
      )}
    </div>
  );
};

export default SectorDetails;
