"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TypeBadge } from "@/components/ui/library/Badge";
import { GradeBadge } from "@/components/ui/library/Badge/GradeBadge";
import { Skeleton } from "@/components/ui/skeleton";
import { getApiUserUserByProfileUserIdAscentsInfiniteOptions } from "@/lib/api/@tanstack/react-query.gen";
import type { UserAscentDto } from "@/lib/api/types.gen";
import { formatClimbType, formatHoldType, formatRockType } from "@/lib/utils/formatters";
import { useInfiniteQuery } from "@tanstack/react-query";
import { format, isValid, parseISO } from "date-fns";
import { CalendarIcon, Star } from "lucide-react";
import Link from "next/link";
import { Fragment, useCallback, useEffect, useMemo } from "react";

interface ProfileAscentsTableProps {
  userId: string;
}

export function ProfileAscentsTable({ userId }: ProfileAscentsTableProps) {
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage, isLoading, error } = useInfiniteQuery({
    ...getApiUserUserByProfileUserIdAscentsInfiniteOptions({
      path: { profileUserId: userId },
      query: { page: 0, pageSize: 5 },
    }),
    enabled: !!userId,
    getNextPageParam: (lastPage, allPages) => {
      if (!lastPage?.ascents || lastPage.ascents.length === 0) return undefined;
      return allPages.length; // next page index (0-based)
    },
  });

  // Group ascents by date
  const groupedAscents = useMemo(() => {
    if (!data?.pages) return [];

    const allAscents = data.pages.flatMap((page) => page.ascents || []);
    const groups: Record<string, UserAscentDto[]> = {};

    allAscents.forEach((ascent) => {
      if (!ascent.ascentDate) return;

      try {
        const date = parseISO(ascent.ascentDate);
        if (isValid(date)) {
          const dateKey = format(date, "yyyy-MM-dd");
          if (!groups[dateKey]) {
            groups[dateKey] = [];
          }
          groups[dateKey].push(ascent);
        }
      } catch {
        console.warn("Invalid date format:", ascent.ascentDate);
      }
    });

    // Convert to array and sort by date (newest first)
    return Object.entries(groups)
      .map(([date, ascents]) => ({
        date,
        ascents: ascents.sort((a, b) => {
          // Sort ascents within the same date by creation time if available
          if (a.ascentDate && b.ascentDate) {
            return new Date(b.ascentDate).getTime() - new Date(a.ascentDate).getTime();
          }
          return 0;
        }),
      }))
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  }, [data?.pages]);

  // Infinite scroll handler
  const handleScroll = useCallback(() => {
    if (window.innerHeight + document.documentElement.scrollTop >= document.documentElement.offsetHeight - 1000) {
      if (hasNextPage && !isFetchingNextPage) {
        fetchNextPage();
      }
    }
  }, [hasNextPage, isFetchingNextPage, fetchNextPage]);

  useEffect(() => {
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, [handleScroll]);

  const formatAscentDate = (dateStr: string) => {
    try {
      const date = parseISO(dateStr);
      if (isValid(date)) {
        return format(date, "MMMM d, yyyy");
      }
    } catch {
      console.warn("Invalid date format:", dateStr);
    }
    return "Unknown date";
  };

  // Simple ascent type badge styling similar to AscentDialog
  const renderAscentTypeBadge = (ascentType?: string) => {
    if (!ascentType) return null;
    return <span className="bg-primary/10 text-primary rounded-md px-2 py-0.5 text-xs">{ascentType}</span>;
  };

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Ascents History</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="space-y-2">
                <Skeleton className="h-6 w-32" />
                <div className="space-y-2">
                  {[...Array(3)].map((_, j) => (
                    <div key={j} className="grid grid-cols-6 gap-4">
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
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Ascents History</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-destructive p-4">Error loading ascents.</div>
        </CardContent>
      </Card>
    );
  }

  if (groupedAscents.length === 0) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Ascents History</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">No ascents recorded yet.</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Ascents History</CardTitle>
      </CardHeader>
      <CardContent>
        {groupedAscents.map((group, groupIndex) => (
          <Fragment key={`date-${group.date}`}>
            {/* Spacing between groups */}
            {groupIndex > 0 && <div className="h-8" />}

            {/* Date Header */}
            <div className="bg-muted/30 rounded-md py-3 text-center text-lg font-semibold">
              {formatAscentDate(group.date)}
            </div>

            <div className="mt-3 space-y-3">
              {group.ascents.map((ascent) => (
                <div
                  key={ascent.id}
                  className="flex flex-col gap-3 rounded-lg border p-3 sm:grid sm:grid-cols-4 sm:items-center sm:gap-4"
                >
                  {/* Part 1: Route name + ascent type */}
                  <div className="space-y-1">
                    <h4 className="leading-none font-medium">
                      <Link
                        href={`/crag/${ascent.cragId}?sectorId=${ascent.sectorId}?routeId=${ascent.routeId}`}
                        className="hover:underline"
                      >
                        {ascent.routeName || "Unknown Route"}
                      </Link>
                    </h4>
                    {renderAscentTypeBadge(ascent.ascentType)}
                  </div>

                  {/* Part 2: Date, note, and route types */}
                  <div className="text-muted-foreground space-y-2 text-sm">
                    {ascent.ascentDate && (
                      <div className="flex items-center justify-start gap-2">
                        <CalendarIcon className="h-4 w-4" />
                        <span>{formatAscentDate(ascent.ascentDate)}</span>
                      </div>
                    )}

                    {ascent.notes && <p className="whitespace-pre-line italic">{ascent.notes}</p>}

                    {(!!ascent.climbTypes?.length || !!ascent.rockTypes?.length || !!ascent.holdTypes?.length) && (
                      <div className="flex flex-wrap gap-1 pt-1">
                        {ascent.climbTypes?.map((type) => (
                          <TypeBadge key={`${ascent.id}-climb-${type}`} label={formatClimbType(type)} />
                        ))}
                        {ascent.rockTypes?.map((type) => (
                          <TypeBadge key={`${ascent.id}-rock-${type}`} label={formatRockType(type)} />
                        ))}
                        {ascent.holdTypes?.map((type) => (
                          <TypeBadge key={`${ascent.id}-hold-${type}`} label={formatHoldType(type)} />
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Part 3: Proposed grade */}
                  <div className="flex justify-start sm:justify-end">
                    <div className="flex items-center gap-2">
                      <span className="text-muted-foreground text-sm">Proposed Grade:</span>
                      {ascent.proposedGrade ? <GradeBadge grade={ascent.proposedGrade} /> : <span>-</span>}
                    </div>
                  </div>

                  {/* Part 4: Rating */}
                  <div className="flex justify-start sm:justify-end">
                    {ascent.rating && ascent.rating > 0 ? (
                      <div className="flex items-center">
                        {Array.from({ length: 5 }).map((_, index) => (
                          <Star
                            key={`star-${ascent.id}-${index}`}
                            className={`h-4 w-4 ${index < (ascent.rating ?? 0) ? "fill-yellow-500 text-yellow-500" : "text-gray-300"}`}
                          />
                        ))}
                      </div>
                    ) : (
                      <span>-</span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </Fragment>
        ))}

        {isFetchingNextPage && (
          <div className="space-y-3 py-4">
            {[...Array(2)].map((_, idx) => (
              <Skeleton key={`skeleton-${idx}`} className="h-32 w-full" />
            ))}
          </div>
        )}

        {!hasNextPage && groupedAscents.length > 0 && (
          <div className="text-muted-foreground py-4 text-center">No more ascents to load</div>
        )}
      </CardContent>
    </Card>
  );
}
