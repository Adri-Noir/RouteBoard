import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

export default function ProfileDetailsSkeleton() {
  return (
    <div className="space-y-8 p-4">
      {/* Stats Card */}
      <Card>
        <CardContent className="flex items-center space-x-6 py-6">
          <Skeleton className="h-16 w-16 rounded-full" />
          <div className="flex flex-1 flex-col space-y-2">
            <Skeleton className="h-6 w-32" /> {/* Name */}
            <Skeleton className="h-4 w-24" /> {/* Username */}
          </div>
          <div className="grid w-1/2 grid-cols-3 gap-4">
            <Skeleton className="h-8 w-full" />
            <Skeleton className="h-8 w-full" />
            <Skeleton className="h-8 w-full" />
          </div>
        </CardContent>
      </Card>

      {/* Recently Ascended Card */}
      <Card>
        <CardHeader>
          <CardTitle>Recently Ascended</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="relative w-full md:px-12">
            {/* Carousel Arrows (hidden on mobile) */}
            <Skeleton className="absolute top-1/2 left-0 z-10 hidden h-10 w-10 -translate-y-1/2 rounded-full md:inline-flex" />
            <Skeleton className="absolute top-1/2 right-0 z-10 hidden h-10 w-10 -translate-y-1/2 rounded-full md:inline-flex" />
            <div className="-ml-2 flex space-x-6 overflow-x-auto pb-2 md:-ml-4">
              {[...Array(2)].map((_, i) => (
                <div key={i} className="pl-2 md:basis-1/2 md:pl-4">
                  <div className="hover:border-primary/50 flex h-full gap-4 rounded-lg border p-4 transition-all duration-200 hover:shadow-lg">
                    <Skeleton className="bg-muted h-32 w-24 flex-shrink-0 rounded-md md:h-64 md:w-48" />
                    <div className="flex min-w-0 flex-1 flex-col justify-center">
                      <div className="mb-1 flex items-center justify-center gap-2">
                        <Skeleton className="h-5 w-24" /> {/* Route name */}
                        <Skeleton className="h-6 w-10 rounded-md" /> {/* Grade badge */}
                      </div>
                      <Skeleton className="mx-auto mb-1 h-4 w-32" /> {/* Crag/Sector */}
                      <Skeleton className="mx-auto h-4 w-20" /> {/* Ascents */}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Ascents by Route Type Card */}
      <Card>
        <CardHeader>
          <CardTitle>Ascents by Route Type</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Table Skeleton */}
          <div className="space-y-4">
            <div className="mb-2 grid grid-cols-[2fr_repeat(4,1fr)] gap-4">
              <Skeleton className="h-4" /> {/* Route Type */}
              <Skeleton className="h-4" /> {/* Onsight */}
              <Skeleton className="h-4" /> {/* Flash */}
              <Skeleton className="h-4" /> {/* Redpoint */}
              <Skeleton className="h-4" /> {/* Aid */}
            </div>
            <div className="space-y-2">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="grid grid-cols-[2fr_repeat(4,1fr)] gap-4">
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                </div>
              ))}
            </div>
          </div>
          {/* Chart Skeleton */}
          <div className="flex h-32 items-end justify-center space-x-4">
            {[...Array(5)].map((_, i) => (
              <Skeleton key={i} className="h-24 w-8 rounded-2xl" />
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Grade Distribution Card */}
      <Card>
        <CardHeader>
          <CardTitle>Grade Distribution</CardTitle>
          <Skeleton className="mt-2 h-4 w-48" /> {/* Subtitle */}
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex h-32 items-end justify-center space-x-4">
            {[...Array(5)].map((_, i) => (
              <Skeleton key={i} className="h-24 w-8 rounded-2xl" />
            ))}
          </div>
          <div className="flex items-center justify-between">
            <Skeleton className="h-4 w-32" /> {/* Median grade */}
            <Skeleton className="h-4 w-48" /> {/* Distribution info */}
          </div>
        </CardContent>
      </Card>

      {/* Ascents History Table */}
      <Card>
        <CardHeader>
          <CardTitle>Ascents History</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[...Array(3)].map((_, groupIndex) => (
              <div key={groupIndex} className="space-y-2">
                {/* Date Header Skeleton */}
                <div className="bg-muted/30 rounded-md p-3">
                  <Skeleton className="mx-auto h-6 w-32" />
                </div>
                {/* Ascent Rows Skeleton */}
                <div className="space-y-2">
                  {[...Array(2)].map((_, ascentIndex) => (
                    <div key={ascentIndex} className="grid grid-cols-6 gap-4 rounded-md border p-2">
                      <div className="space-y-1">
                        <Skeleton className="h-4 w-full" /> {/* Route name */}
                        <Skeleton className="h-3 w-3/4" /> {/* Crag/Sector */}
                      </div>
                      <div className="space-y-1">
                        <Skeleton className="h-3 w-full" /> {/* Notes line 1 */}
                        <Skeleton className="h-3 w-2/3" /> {/* Notes line 2 */}
                      </div>
                      <Skeleton className="h-6 w-12 rounded-md" /> {/* Grade badge */}
                      <Skeleton className="h-6 w-16 rounded-md" /> {/* Ascent type badge */}
                      <Skeleton className="h-4 w-full" /> {/* Attempts */}
                      <div className="flex space-x-1">
                        {[...Array(5)].map((_, starIndex) => (
                          <Skeleton key={starIndex} className="h-3 w-3" /> /* Stars */
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
