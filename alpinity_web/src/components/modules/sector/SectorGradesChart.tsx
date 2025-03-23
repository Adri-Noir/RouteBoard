import { calculateGradeDistribution, GradeDistributionCard } from "@/components/modules/charts/GradeDistributionChart";
import { SectorDetailedDto } from "@/lib/api/types.gen";
import { useMemo, useState } from "react";

interface SectorGradesChartProps {
  sector: SectorDetailedDto;
  onFilterChange?: (grade: string | null) => void;
}

const SectorGradesChart = ({ sector, onFilterChange }: SectorGradesChartProps) => {
  const [selectedGrade, setSelectedGrade] = useState<string | null>(null);

  // Calculate grade distribution
  const gradeDistribution = useMemo(() => {
    return calculateGradeDistribution(sector.routes || []);
  }, [sector.routes]);

  const handleGradeSelection = (grade: string | null) => {
    setSelectedGrade(grade);
    onFilterChange?.(grade);
  };

  if (gradeDistribution.length === 0) {
    return null;
  }

  const totalRoutes = sector.routes?.length || 0;

  return (
    <GradeDistributionCard
      distribution={gradeDistribution}
      totalRoutes={totalRoutes}
      selectedGrade={selectedGrade}
      onSelectGrade={handleGradeSelection}
      description="Climbing grades in this sector"
      itemName="sector"
    />
  );
};

export default SectorGradesChart;
