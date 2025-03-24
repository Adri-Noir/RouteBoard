"use client";

import { Skeleton } from "@/components/ui/skeleton";
import { getApiMapExploreOptions } from "@/lib/api/@tanstack/react-query.gen";
import { useQuery } from "@tanstack/react-query";
import { ExploreCard } from "./ExploreCard";

const ExploreCardSkeleton = () => {
  return (
    <div className="mt-8 grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
      {Array(6)
        .fill(0)
        .map((_, i) => (
          <Skeleton key={i} className="h-60 w-full rounded-md" />
        ))}
    </div>
  );
};

export function ExploreList() {
  const { data: exploreData, isLoading } = useQuery({
    ...getApiMapExploreOptions(),
    refetchOnWindowFocus: false,
  });

  if (isLoading) {
    return <ExploreCardSkeleton />;
  }

  if (!exploreData || exploreData.length === 0) {
    return (
      <div className="py-12 text-center">
        <h3 className="text-muted-foreground text-xl font-medium">No crags found</h3>
        <p className="text-muted-foreground mt-2 text-sm">Try adjusting your search criteria</p>
      </div>
    );
  }

  return (
    <div className="mt-8 grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
      {exploreData.map((item) => (
        <ExploreCard key={item.id} data={item} />
      ))}
    </div>
  );
}
