"use client";

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { getApiCragByIdOptions, getApiSectorByIdOptions } from "@/lib/api/@tanstack/react-query.gen";
import { CragDetailedDto } from "@/lib/api/types.gen";
import useAuth from "@/lib/hooks/useAuth";
import { useQuery } from "@tanstack/react-query";
import { AlertCircle } from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import SectorDetails from "../sector/SectorDetails";
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

  const {
    data: selectedSector,
    error: sectorError,
    isLoading: sectorIsLoading,
  } = useQuery({
    ...getApiSectorByIdOptions({
      path: {
        id: selectedSectorId || "",
      },
    }),
    enabled: isAuthenticated && !!selectedSectorId,
  });

  const handleSectorChange = useMemo(
    () => (sectorId: string) => {
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

  useEffect(() => {
    if (!initialSectorId) {
      setSelectedSectorId(crag?.sectors?.[0]?.id);
    }
  }, [initialSectorId, crag?.sectors]);

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
    <div className="space-y-8">
      <CragHeader name={crag.name || "Unnamed Crag"} description={crag.description} locationName={crag.locationName} />

      {crag.photos && crag.photos.length > 0 && (
        <section className="rounded-lg border p-4">
          <h2 className="mb-4 text-2xl font-semibold">Photos</h2>
          <CragPhotos photos={crag.photos} />
        </section>
      )}

      {crag.location && (
        <section className="rounded-lg border p-4">
          <h2 className="mb-4 text-2xl font-semibold">Location</h2>
          <CragLocation
            location={crag.location}
            sectors={sectors}
            onSectorClick={handleSectorChange}
            selectedSectorId={selectedSectorId}
          />
        </section>
      )}

      {cragId && (
        <section className="rounded-lg border p-4">
          <h2 className="mb-4 text-2xl font-semibold">Weather</h2>
          <CragWeather cragId={cragId} />
        </section>
      )}

      {crag.sectors && crag.sectors.length > 0 && (
        <section className="rounded-lg border p-4">
          <h2 className="mb-4 text-2xl font-semibold">Sectors</h2>

          <div className="space-y-8">
            {/* Sector Selection */}
            <div className="flex flex-wrap gap-2">
              {crag.sectors.map((sector) => (
                <button
                  key={sector.id}
                  onClick={() => handleSectorChange(sector.id)}
                  className={`rounded-full px-4 py-2 text-sm font-medium transition-colors ${
                  selectedSectorId === sector.id
                      ? "bg-primary text-primary-foreground"
                      : "bg-secondary hover:bg-secondary/80 text-secondary-foreground"
                  }`}
                >
                  {sector.name || "Unnamed Sector"}
                  {sector.routesCount !== undefined && (
                    <span className="ml-1 text-xs opacity-70">({sector.routesCount})</span>
                  )}
                </button>
              ))}
            </div>

            {/* Selected Sector Details */}
            {selectedSectorId && (
              <>
                {sectorError ? (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertTitle>Error</AlertTitle>
                    <AlertDescription>Failed to load sector details. Please try again later.</AlertDescription>
                  </Alert>
                ) : sectorIsLoading ? (
                  <div className="flex h-64 items-center justify-center">
                    <div className="animate-pulse">Loading sector details...</div>
                  </div>
                ) : selectedSector ? (
                  <SectorDetails sector={selectedSector} />
                ) : null}
              </>
            )}
          </div>
        </section>
      )}
    </div>
  );
};

export default CragDetails;
