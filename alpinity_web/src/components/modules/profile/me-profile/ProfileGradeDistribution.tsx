"use client";

import type { GradeDistributionItem } from "@/components/modules/charts/GradeDistributionChart";
import { GradeDistributionCard } from "@/components/modules/charts/GradeDistributionChart";
import type { GradeCountDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { useState } from "react";

interface ProfileGradeDistributionProps {
  data: GradeCountDto[];
}

export function ProfileGradeDistribution({ data }: ProfileGradeDistributionProps) {
  const [selectedGrade, setSelectedGrade] = useState<string | null>(null);

  const countsMap: Record<string, number> = {};
  data.forEach((gc) => {
    if (gc.climbingGrade) {
      const grade = formatClimbingGrade(gc.climbingGrade);
      countsMap[grade] = (countsMap[grade] || 0) + (gc.count ?? 0);
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
      itemName="user's ascents"
      title="Grade Distribution"
      enableFilter={false}
    />
  );
}
