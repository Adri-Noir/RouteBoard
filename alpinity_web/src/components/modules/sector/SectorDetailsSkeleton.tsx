"use client";

import { Skeleton } from "@/components/ui/skeleton";

const SectorDetailsSkeleton = () => {
  return (
    <div className="space-y-8">
      <div className="space-y-2">
        <Skeleton className="h-6 w-40" />
        <Skeleton className="h-10 w-3/4" />
        <Skeleton className="h-6 w-full" />
      </div>

      <section className="rounded-lg border p-4">
        <Skeleton className="mb-4 h-8 w-32" />
        <div className="space-y-4">
          <Skeleton className="aspect-video h-64 w-full rounded-lg" />
        </div>
      </section>

      <section className="rounded-lg border p-4">
        <Skeleton className="mb-4 h-8 w-32" />
        <div className="space-y-4">
          <Skeleton className="h-6 w-60" />
          <Skeleton className="aspect-video h-64 w-full rounded-lg" />
        </div>
      </section>

      <section className="rounded-lg border p-4">
        <Skeleton className="mb-4 h-8 w-32" />
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="space-y-2 rounded-lg border p-4">
              <div className="flex items-center justify-between">
                <Skeleton className="h-6 w-40" />
                <Skeleton className="h-6 w-12" />
              </div>
              <Skeleton className="h-4 w-24" />
              <Skeleton className="h-12 w-full" />
              <div className="flex items-center justify-between">
                <Skeleton className="h-4 w-20" />
                <Skeleton className="h-8 w-24" />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default SectorDetailsSkeleton;
