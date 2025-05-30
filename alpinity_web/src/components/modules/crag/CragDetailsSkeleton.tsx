import { Skeleton } from "@/components/ui/skeleton";

const CragDetailsSkeleton = () => {
  return (
    <div className="space-y-8 px-0 sm:px-6 lg:px-8">
      {/* Header */}
      <div className="space-y-4 p-4">
        <Skeleton className="h-14 w-40 md:w-64" /> {/* Responsive Title */}
        <Skeleton className="h-5 w-28 md:w-48" /> {/* Responsive Subtitle */}
        <Skeleton className="h-5 w-48 md:w-80" /> {/* Responsive Description */}
      </div>

      {/* Weather Section */}
      <section className="space-y-4 rounded-lg border p-6">
        <Skeleton className="mb-2 h-7 w-32" /> {/* Section Title */}
        <div className="flex min-h-[96px] items-center justify-between rounded-lg border p-6">
          <div className="space-y-3">
            <Skeleton className="h-5 w-24" /> {/* Weather label */}
            <div className="flex items-center space-x-4">
              <Skeleton className="h-10 w-10 rounded-full" /> {/* Larger Weather icon */}
              <div>
                <Skeleton className="h-7 w-20" /> {/* Larger Temperature */}
                <Skeleton className="h-5 w-24" /> {/* Larger Description */}
              </div>
            </div>
          </div>
          <div className="space-y-3 text-right">
            <Skeleton className="h-5 w-14" /> {/* Wind */}
            <Skeleton className="h-5 w-12" /> {/* Humidity */}
          </div>
        </div>
      </section>

      {/* Location Section */}
      <section className="space-y-4 rounded-lg border p-6">
        <Skeleton className="mb-2 h-7 w-32" /> {/* Section Title */}
        <Skeleton className="h-[400px] w-full rounded-md" /> {/* Map - taller to match CragLocation */}
      </section>

      {/* Sectors & Routes Section */}
      <section className="space-y-6 rounded-lg border p-6">
        <Skeleton className="mb-2 h-7 w-32" /> {/* Section Title */}
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <Skeleton className="h-8 w-40" /> {/* Dropdown */}
        </div>
        {/* Grade Distribution Chart (Graph) - full width above table */}
        <div className="mb-6 w-full space-y-4 rounded-lg border p-4">
          <Skeleton className="h-4 w-32" /> {/* Chart Title */}
          <div className="flex h-32 w-full items-end justify-center space-x-4">
            {[...Array(4)].map((_, i) => (
              <Skeleton key={i} className="h-24 w-8 rounded-2xl" />
            ))}
          </div>
          <Skeleton className="h-4 w-24" /> {/* Median grade */}
        </div>
        {/* Table Skeleton */}
        <div className="rounded-lg border p-4">
          <div className="mb-8 grid grid-cols-4 items-center space-x-2">
            <Skeleton className="h-8" /> {/* Search */}
            <Skeleton className="h-8" /> {/* Filter */}
            <Skeleton className="h-8" /> {/* Filter */}
            <Skeleton className="h-8" /> {/* Reset */}
          </div>
          <div className="space-y-4">
            {/* Table header */}
            <div className="grid grid-cols-[2fr_1fr_1fr_1fr_1fr_1fr] items-center space-x-4">
              <Skeleton className="h-4" /> {/* Name */}
              <Skeleton className="h-4" /> {/* Grade */}
              <Skeleton className="h-4" /> {/* Type */}
              <Skeleton className="h-4" /> {/* Sector */}
              <Skeleton className="h-4" /> {/* Ascents */}
              <Skeleton className="h-4" /> {/* Actions */}
            </div>
            {/* Table rows */}
            <div className="space-y-2">
              {[...Array(3)].map((_, i) => (
                <div key={i} className="grid grid-cols-[2fr_1fr_1fr_1fr_1fr_1fr] items-center space-x-4 py-2">
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                  <Skeleton className="h-4" />
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default CragDetailsSkeleton;
