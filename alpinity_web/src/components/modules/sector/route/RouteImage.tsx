"use client";

import { GradeBadge } from "@/components/ui/library/Badge";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { SectorRouteDto } from "@/lib/api/types.gen";

interface RouteImageProps {
  selectedRoute: SectorRouteDto | undefined;
}

const RouteImage = ({ selectedRoute }: RouteImageProps) => {
  const selectedRouteImage = selectedRoute?.routePhotos?.[0]?.combinedPhoto?.url;

  return (
    <div className="relative order-2 col-span-1 lg:order-1 lg:col-span-2">
      {selectedRouteImage ? (
        <ImageWithLoading
          src={selectedRouteImage}
          alt={selectedRoute?.name || "Route image"}
          fill
          sizes="(max-width: 1024px) 100vw, 66vw"
          priority
          containerClassName="h-[75vh] max-h-[900px] w-full rounded-lg border bg-muted"
        />
      ) : (
        <div className="bg-muted text-muted-foreground flex h-[75vh] max-h-[900px] w-full items-center justify-center rounded-lg border">
          No route image available
        </div>
      )}

      {selectedRoute && (
        <div className="mt-4 text-center">
          <h4 className="text-xl font-semibold">{selectedRoute.name}</h4>
          {selectedRoute.grade && (
            <GradeBadge grade={selectedRoute.grade} className="mt-1 inline-block px-3 py-1 text-lg" />
          )}
        </div>
      )}
    </div>
  );
};

export default RouteImage;
