import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SectorDetailedDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { ChevronRight } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

interface SectorRoutesProps {
  sector: SectorDetailedDto;
}

const SectorRoutes = ({ sector }: SectorRoutesProps) => {
  const [selectedRouteId, setSelectedRouteId] = useState<string | undefined>(
    sector.routes && sector.routes.length > 0 ? sector.routes[0].id : undefined,
  );

  const selectedRoute = sector.routes?.find((route) => route.id === selectedRouteId);
  const selectedRouteImage = selectedRoute?.routePhotos?.[0]?.image?.url;

  if (!sector.routes || sector.routes.length === 0) {
    return null;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Routes</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          {/* Left side: Route image (vertical) - takes 2/3 of space */}
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

          {/* Right side: Routes list - takes 1/3 of space */}
          <div className="order-1 flex max-h-[75vh] flex-col overflow-y-auto lg:order-2">
            <div className="divide-y rounded-lg border">
              {sector.routes.map((route) => (
                <div
                  key={route.id}
                  className={`hover:bg-accent/50 flex cursor-pointer flex-col p-3 transition-all ${selectedRouteId === route.id ? "bg-accent/80" : ""}`}
                  onClick={() => setSelectedRouteId(route.id)}
                >
                  <div className="flex items-center justify-between">
                    <h4 className="font-medium">{route.name || "Unnamed Route"}</h4>
                    {route.grade && (
                      <span className="bg-primary/10 text-primary rounded-md px-2 py-1 text-xs font-semibold">
                        {formatClimbingGrade(route.grade)}
                      </span>
                    )}
                  </div>

                  {(route.routeType && route.routeType.length > 0) || route.description ? (
                    <div className="mt-1 flex flex-col">
                      {route.routeType && route.routeType.length > 0 && (
                        <span className="text-muted-foreground text-xs">{route.routeType.join(", ")}</span>
                      )}

                      {route.description && (
                        <p className="text-muted-foreground mt-1 line-clamp-1 text-xs">{route.description}</p>
                      )}
                    </div>
                  ) : null}

                  <div className="mt-2 flex items-center justify-between">
                    <div className="text-muted-foreground text-xs">
                      {route.ascentsCount && route.ascentsCount > 0 && (
                        <span>
                          {route.ascentsCount} {route.ascentsCount === 1 ? "ascent" : "ascents"}
                        </span>
                      )}
                    </div>
                    <Button asChild size="sm" variant="ghost" className="h-6 px-2 text-xs">
                      <Link href={`/route/${route.id}`}>
                        Details
                        <ChevronRight className="ml-1 h-3 w-3" />
                      </Link>
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default SectorRoutes;
