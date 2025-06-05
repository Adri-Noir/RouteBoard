"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { GradeBadge } from "@/components/ui/library/Badge/GradeBadge";
import { Skeleton } from "@/components/ui/skeleton";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { getApiUserUserByProfileUserIdAscentsInfiniteOptions } from "@/lib/api/@tanstack/react-query.gen";
import type { UserAscentDto } from "@/lib/api/types.gen";
import { useInfiniteQuery } from "@tanstack/react-query";
import { format, isValid, parseISO } from "date-fns";
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

  const getAscentTypeColor = (ascentType?: string) => {
    switch (ascentType) {
      case "Onsight":
        return "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200";
      case "Flash":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200";
      case "Redpoint":
        return "bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200";
      case "Aid":
        return "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200";
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200";
    }
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
        <div className="overflow-x-auto">
          <Table className="w-full min-w-[800px]">
            <TableHeader className="sr-only">
              <TableRow>
                <TableHead className="w-[25%] min-w-[150px]">Route</TableHead>
                <TableHead className="w-[47%] min-w-[240px]">Notes</TableHead>
                <TableHead className="w-[9%] min-w-[70px]">Grade</TableHead>
                <TableHead className="w-[8%] min-w-[70px]">Ascent Type</TableHead>
                <TableHead className="w-[6%] min-w-[60px]">Attempts</TableHead>
                <TableHead className="w-[7%] min-w-[60px]">Rating</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {groupedAscents.map((group, groupIndex) => (
                <Fragment key={`date-${group.date}`}>
                  {/* Spacing between groups */}
                  {groupIndex > 0 && (
                    <TableRow className="bg-transparent hover:bg-transparent">
                      <TableCell colSpan={6} className="h-8 border-0 p-0">
                        <div className="h-8" />
                      </TableCell>
                    </TableRow>
                  )}
                  {/* Date Header Row */}
                  <TableRow className="bg-muted/30 hover:bg-muted/30">
                    <TableCell colSpan={6} className="py-3 text-lg font-semibold md:text-center">
                      {formatAscentDate(group.date)}
                    </TableCell>
                  </TableRow>
                  {/* Ascent Rows */}
                  {group.ascents.map((ascent) => (
                    <TableRow key={ascent.id} className="hover:bg-muted/50">
                      <TableCell>
                        <div className="space-y-1">
                          <Link
                            href={`/crag/${ascent.cragId}?sectorId=${ascent.sectorId}?routeId=${ascent.routeId}`}
                            className="block truncate font-medium hover:underline"
                          >
                            {ascent.routeName || "Unknown Route"}
                          </Link>
                          <div className="text-muted-foreground truncate text-sm">
                            {ascent.cragName}
                            {ascent.sectorName && ` - ${ascent.sectorName}`}
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="text-sm">
                          {ascent.notes ? (
                            <div className="text-muted-foreground whitespace-normal italic" title={ascent.notes}>
                              {ascent.notes}
                            </div>
                          ) : (
                            <span className="text-muted-foreground">-</span>
                          )}
                        </div>
                      </TableCell>
                      <TableCell>{ascent.proposedGrade && <GradeBadge grade={ascent.proposedGrade} />}</TableCell>
                      <TableCell>
                        {ascent.ascentType && (
                          <span
                            className={`inline-block rounded-md px-2 py-1 text-xs font-medium ${getAscentTypeColor(ascent.ascentType)}`}
                          >
                            {ascent.ascentType}
                          </span>
                        )}
                      </TableCell>
                      <TableCell className="whitespace-normal">
                        {ascent.numberOfAttempts
                          ? `Number of attempts: ${ascent.numberOfAttempts}`
                          : "Number of attempts: N/A"}
                      </TableCell>
                      <TableCell>
                        {ascent.rating && ascent.rating > 0 ? (
                          <div className="flex items-center justify-start">
                            {Array.from({ length: 5 }).map((_, index) => (
                              <span
                                key={index}
                                className={`text-xs leading-none ${index < ascent.rating! ? "text-yellow-500" : "text-gray-300"}`}
                              >
                                ★
                              </span>
                            ))}
                          </div>
                        ) : (
                          <span className="block text-center">-</span>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </Fragment>
              ))}
            </TableBody>
          </Table>
        </div>

        {isFetchingNextPage && (
          <div className="space-y-2 py-4">
            <div className="grid grid-cols-6 gap-4">
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
            </div>
            <div className="grid grid-cols-6 gap-4">
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
              <Skeleton className="h-4" />
            </div>
          </div>
        )}

        {!hasNextPage && groupedAscents.length > 0 && (
          <div className="text-muted-foreground py-4 text-center">No more ascents to load</div>
        )}
      </CardContent>
    </Card>
  );
}
