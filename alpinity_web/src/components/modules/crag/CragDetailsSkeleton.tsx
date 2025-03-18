import { Skeleton } from "@/components/ui/skeleton";

const CragDetailsSkeleton = () => {
  return (
    <div className="space-y-8">
      <div className="space-y-3">
        <Skeleton className="h-12 w-3/4" />
        <Skeleton className="h-4 w-1/4" />
        <Skeleton className="h-24 w-full" />
      </div>

      <section className="rounded-lg border p-4">
        <Skeleton className="mb-4 h-10 w-32" />
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {[...Array(3)].map((_, i) => (
            <Skeleton key={i} className="aspect-video rounded-md" />
          ))}
        </div>
      </section>

      <section className="rounded-lg border p-4">
        <Skeleton className="mb-4 h-10 w-32" />
        <Skeleton className="h-[300px] w-full rounded-md" />
      </section>

      <section className="rounded-lg border p-4">
        <Skeleton className="mb-4 h-10 w-32" />
        <div className="space-y-4">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="flex items-center space-x-4">
              <Skeleton className="h-12 w-12 rounded-full" />
              <div className="space-y-2">
                <Skeleton className="h-4 w-48" />
                <Skeleton className="h-4 w-24" />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default CragDetailsSkeleton;
