import { SectorRouteDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import Image from "next/image";

interface RouteImageProps {
  selectedRoute: SectorRouteDto | undefined;
}

const RouteImage = ({ selectedRoute }: RouteImageProps) => {
  const selectedRouteImage = selectedRoute?.routePhotos?.[0]?.image?.url;

  return (
    <div className="relative order-2 col-span-1 lg:order-1 lg:col-span-2">
      {selectedRouteImage ? (
        <div className="bg-muted relative h-[75vh] max-h-[900px] w-full overflow-hidden rounded-lg border">
          <Image
            src={selectedRouteImage}
            alt={selectedRoute?.name || "Route image"}
            fill
            className="object-contain"
            sizes="(max-width: 1024px) 100vw, 66vw"
            priority
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
            <span className="text-primary text-lg">{formatClimbingGrade(selectedRoute.grade)}</span>
          )}
        </div>
      )}
    </div>
  );
};

export default RouteImage;
