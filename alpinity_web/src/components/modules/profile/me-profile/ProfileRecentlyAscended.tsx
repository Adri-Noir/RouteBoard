"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from "@/components/ui/carousel";
import { GradeBadge } from "@/components/ui/library/Badge/GradeBadge";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { RecentlyAscendedRouteDto } from "@/lib/api/types.gen";
import Link from "next/link";

interface ProfileRecentlyAscendedProps {
  routes: RecentlyAscendedRouteDto[];
}

export function ProfileRecentlyAscended({ routes }: ProfileRecentlyAscendedProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Recently Ascended</CardTitle>
      </CardHeader>
      <CardContent>
        {routes.length === 0 ? (
          <p className="text-muted-foreground">No recent ascents to display.</p>
        ) : (
          <div className="relative w-full md:px-12">
            <Carousel
              opts={{
                align: "start",
              }}
              className="w-full"
            >
              <CarouselContent className="-ml-2 md:-ml-4">
                {routes.map((route) => {
                  const photoUrl = route.routePhotos?.[0]?.combinedPhoto?.url;
                  return (
                    <CarouselItem key={route.id} className="pl-2 md:pl-4 lg:basis-1/2">
                      <Link
                        href={`/crag/${route.cragId}?sectorId=${route.sectorId}&routeId=${route.id}`}
                        className="block h-full"
                      >
                        <div className="hover:border-primary/50 flex cursor-pointer gap-4 rounded-lg border p-4 transition-all duration-200 hover:shadow-lg">
                          <div className="bg-muted relative h-32 w-24 flex-shrink-0 overflow-hidden rounded-md md:h-64 md:w-48">
                            {photoUrl ? (
                              <ImageWithLoading
                                src={photoUrl}
                                alt={route.name ?? "Route photo"}
                                className="object-cover"
                                fill
                                sizes="(max-width: 768px) 24vw, 48vw"
                                containerClassName="h-full w-full"
                              />
                            ) : (
                              <div className="text-muted-foreground flex h-full w-full items-center justify-center">
                                <span className="text-sm">No photo</span>
                              </div>
                            )}
                          </div>
                          <div className="flex min-w-0 flex-1 flex-col justify-center">
                            <div className="mb-1 flex items-center justify-center gap-2">
                              <h3 className="truncate text-lg font-semibold">{route.name}</h3>
                              {route.grade && <GradeBadge grade={route.grade} />}
                            </div>
                            <p className="text-muted-foreground text-center text-sm">
                              {route.cragName}
                              {route.sectorName ? ` - ${route.sectorName}` : ""}
                            </p>
                            <p className="text-center text-sm">Ascents: {route.ascentsCount ?? 0}</p>
                          </div>
                        </div>
                      </Link>
                    </CarouselItem>
                  );
                })}
              </CarouselContent>
              <CarouselPrevious className="hidden md:inline-flex" />
              <CarouselNext className="hidden md:inline-flex" />
            </Carousel>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
