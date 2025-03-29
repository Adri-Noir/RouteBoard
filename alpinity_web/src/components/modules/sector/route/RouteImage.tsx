"use client";

import { GradeBadge } from "@/components/ui/library/Badge";
import { SectorRouteDto } from "@/lib/api/types.gen";
import Image from "next/image";
import { useState } from "react";

interface RouteImageProps {
  selectedRoute: SectorRouteDto | undefined;
}

const RouteImage = ({ selectedRoute }: RouteImageProps) => {
  const selectedRouteImage = selectedRoute?.routePhotos?.[0]?.combinedPhoto?.url;
  const [isLoading, setIsLoading] = useState(true);

  return (
    <div className="relative order-2 col-span-1 lg:order-1 lg:col-span-2">
      {selectedRouteImage ? (
        <div className="bg-muted relative h-[75vh] max-h-[900px] w-full overflow-hidden rounded-lg border">
          {isLoading && (
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="border-primary h-10 w-10 animate-spin rounded-full border-4 border-t-transparent"></div>
            </div>
          )}
          <Image
            src={selectedRouteImage}
            alt={selectedRoute?.name || "Route image"}
            fill
            className="object-contain"
            sizes="(max-width: 1024px) 100vw, 66vw"
            priority
            onLoad={() => setIsLoading(false)}
          />
        </div>
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
