"use client";

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { getApiCragByIdOptions } from "@/lib/api/@tanstack/react-query.gen";
import { CragDetailedDto } from "@/lib/api/types.gen";
import useAuth from "@/lib/hooks/useAuth";
import { cn } from "@/lib/utils";
import { useQuery } from "@tanstack/react-query";
import { AlertCircle } from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { useCallback, useMemo, useState } from "react";
import SectorDetails from "../sector/SectorDetails";
import SectorSelector from "../sector/SectorSelector";
import CragAllRoutes from "./CragAllRoutes";
import CragDetailsSkeleton from "./CragDetailsSkeleton";
import CragHeader from "./CragHeader";
import CragLocation from "./CragLocation";
import CragPhotos from "./CragPhotos";
import CragWeather from "./CragWeather";

interface CragDetailsProps {
  cragId: string;
  initialData?: CragDetailedDto | null;
}

const CragDetails = ({ cragId, initialData }: CragDetailsProps) => {
  const { isAuthenticated } = useAuth();
  const searchParams = useSearchParams();
  const router = useRouter();

  const initialSectorId = searchParams.get("sectorId") ?? undefined;
  const [selectedSectorId, setSelectedSectorId] = useState<string | undefined>(initialSectorId);

  const {
    data: crag,
    error: cragError,
    isLoading: cragIsLoading,
  } = useQuery({
    ...getApiCragByIdOptions({
      path: {
        id: cragId,
      },
    }),
    initialData: initialData ?? undefined,
    enabled: isAuthenticated,
  });

  const selectedSector = useMemo(() => {
    return crag?.sectors?.find((sector) => sector.id === selectedSectorId);
  }, [crag?.sectors, selectedSectorId]);

  const handleSectorChange = useCallback(
    (sectorId: string) => {
      setSelectedSectorId(sectorId);
      const params = new URLSearchParams();
      params.set("sectorId", sectorId);
      router.push(`/crag/${cragId}?${params.toString()}`, { scroll: false });
    },
    [cragId, router],
  );

  const sectors = useMemo(
    () =>
      crag?.sectors
        ?.filter(
          (sector) =>
            sector.location &&
            typeof sector.location.latitude === "number" &&
            typeof sector.location.longitude === "number",
        )
        .map((sector) => ({
          latitude: sector.location!.latitude,
          longitude: sector.location!.longitude,
          id: sector.id,
        })),
    [crag?.sectors],
  );

  if (cragError) {
    return (
      <Alert variant="destructive">
        <AlertCircle className="h-4 w-4" />
        <AlertTitle>Error</AlertTitle>
        <AlertDescription>Failed to load crag details. Please try again later.</AlertDescription>
      </Alert>
    );
  }

  if (cragIsLoading || !crag) {
    return <CragDetailsSkeleton />;
  }

  return (
    <div className="space-y-8 px-0 sm:px-6 lg:px-8">
      <CragHeader name={crag.name || "Unnamed Crag"} description={crag.description} locationName={crag.locationName} />

      {cragId && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">Weather</h2>
          <CragWeather cragId={cragId} />
        </section>
      )}

      {crag.location && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">Location</h2>
          <CragLocation
            location={crag.location}
            sectors={sectors}
            onSectorClick={handleSectorChange}
            selectedSectorId={selectedSectorId}
          />
        </section>
      )}

      {crag.photos && crag.photos.length > 0 && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">Photos</h2>
          <CragPhotos photos={crag.photos} />
        </section>
      )}

      {crag.sectors && crag.sectors.length > 0 && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">Sectors</h2>

          <div className={cn(selectedSectorId ? "space-y-0" : "space-y-8")}>
            {/* Sector Selection */}
            <div>
              <SectorSelector
                sectors={crag.sectors}
                currentSectorId={selectedSectorId}
                onSectorChange={(sectorId) => {
                  if (sectorId) {
                    handleSectorChange(sectorId);
                  } else {
                    setSelectedSectorId(undefined);
                    router.push(`/crag/${cragId}`, { scroll: false });
                  }
                }}
              />
            </div>

            {/* Selected Sector Details or All Routes Table */}
            {selectedSectorId ? (
              <>{selectedSector ? <SectorDetails sector={selectedSector} /> : null}</>
            ) : (
              <CragAllRoutes crag={crag} />
            )}
          </div>
        </section>
      )}
    </div>
  );
};

export default CragDetails;
