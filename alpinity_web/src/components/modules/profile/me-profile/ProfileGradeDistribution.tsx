"use client";

import type { GradeDistributionItem } from "@/components/modules/charts/GradeDistributionChart";
import { GradeDistributionCard } from "@/components/modules/charts/GradeDistributionChart";
import type { ClimbingGradeAscentCountDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { useState } from "react";

interface ProfileGradeDistributionProps {
  data: ClimbingGradeAscentCountDto[];
  filterRouteType?: string | null;
}

export function ProfileGradeDistribution({ data, filterRouteType }: ProfileGradeDistributionProps) {
  const [selectedGrade, setSelectedGrade] = useState<string | null>(null);

  // Aggregate counts by grade, optionally filtering by route type
  const countsMap: Record<string, number> = {};
  data.forEach((item) => {
    if (!filterRouteType || item.routeType === filterRouteType) {
      item.gradeCount?.forEach((gc) => {
        if (gc.climbingGrade) {
          const grade = formatClimbingGrade(gc.climbingGrade);
          countsMap[grade] = (countsMap[grade] || 0) + (gc.count ?? 0);
        }
      });
    }
  });

  const distribution: GradeDistributionItem[] = Object.entries(countsMap).map(([grade, count]) => ({ grade, count }));

  const totalRoutes = distribution.reduce((sum, g) => sum + g.count, 0);

  return (
    <GradeDistributionCard
      distribution={distribution}
      totalRoutes={totalRoutes}
      selectedGrade={selectedGrade}
      onSelectGrade={setSelectedGrade}
      itemName={filterRouteType ? filterRouteType : "all routes"}
      title={filterRouteType ? `Grade Distribution for ${filterRouteType}` : "Grade Distribution"}
      enableFilter={false}
    />
  );
}
