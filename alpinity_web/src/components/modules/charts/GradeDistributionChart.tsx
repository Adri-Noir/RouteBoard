import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartConfig, ChartContainer } from "@/components/ui/chart";
import { ClimbingGrade } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { TrendingUp } from "lucide-react";
import { useMemo } from "react";
import { Bar, BarChart, CartesianGrid, LabelList, Rectangle, XAxis } from "recharts";

export interface GradeDistributionItem {
  grade: string;
  count: number;
}

interface GradeChartProps {
  distribution: GradeDistributionItem[];
  chartWidth: string;
  chartConfig: ChartConfig;
  selectedGrade: string | null;
  onSelectGrade: (grade: string) => void;
}

const GradeChart = ({ distribution, chartWidth, chartConfig, selectedGrade, onSelectGrade }: GradeChartProps) => {
  // Find the index of the selected grade in the distribution array
  const activeGradeIndex = selectedGrade ? distribution.findIndex((item) => item.grade === selectedGrade) : -1;

  return (
    <ChartContainer
      config={chartConfig}
      className="h-[200px]"
      style={{
        width: chartWidth,
      }}
    >
      <BarChart
        accessibilityLayer
        data={distribution}
        barSize={30}
        margin={{
          top: 20,
        }}
      >
        <CartesianGrid horizontal={false} vertical={false} />
        <XAxis dataKey="grade" tickLine={false} tickMargin={10} axisLine={false} />
        <Bar
          dataKey="count"
          fill="var(--color-count)"
          radius={20}
          cursor="pointer"
          onClick={(data) => {
            if (data && data.grade) {
              onSelectGrade(data.grade);
            }
          }}
          activeIndex={activeGradeIndex >= 0 ? activeGradeIndex : undefined}
          activeBar={({ ...props }) => {
            return (
              <Rectangle
                {...props}
                fillOpacity={1}
                stroke="var(--color-count)"
                strokeWidth={2}
                strokeDasharray={4}
                strokeDashoffset={4}
              />
            );
          }}
        >
          <LabelList dataKey="count" position="top" offset={12} className="fill-foreground" fontSize={12} />
        </Bar>
      </BarChart>
    </ChartContainer>
  );
};

interface SelectedGradeBadgeProps {
  grade: string;
  onClear: () => void;
}

const SelectedGradeBadge = ({ grade, onClear }: SelectedGradeBadgeProps) => {
  return (
    <div className="flex items-center gap-1">
      <span className="bg-primary text-primary-foreground rounded-md px-2 py-1 text-xs font-semibold">{grade}</span>
      <Button variant="ghost" size="sm" onClick={onClear} className="h-6 w-6 p-0">
        <span className="sr-only">Clear grade filter</span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className="h-3 w-3"
        >
          <path d="M18 6 6 18" />
          <path d="m6 6 12 12" />
        </svg>
      </Button>
    </div>
  );
};

interface StatsFooterProps {
  averageGrade: string;
  totalRoutes: number;
  filteredCount: number;
  isFiltered: boolean;
  itemName?: string;
}

const StatsFooter = ({
  averageGrade,
  totalRoutes,
  filteredCount,
  isFiltered,
  itemName = "sector",
}: StatsFooterProps) => {
  return (
    <div className="mt-4 flex flex-col items-center justify-between gap-2 text-sm md:flex-row">
      <div className="flex gap-2 leading-none font-medium">
        Median grade: {averageGrade} <TrendingUp className="h-4 w-4" />
      </div>
      <div className="text-muted-foreground leading-none">
        {isFiltered
          ? `Showing ${filteredCount} of ${totalRoutes} routes`
          : `Showing distribution for ${totalRoutes} routes in this ${itemName}`}
      </div>
    </div>
  );
};

interface GradeDistributionCardProps {
  distribution: GradeDistributionItem[];
  totalRoutes: number;
  title?: string;
  description?: string;
  selectedGrade: string | null;
  onSelectGrade: (grade: string | null) => void;
  itemName?: string;
  asContainer?: boolean;
}

export const GradeDistributionCard = ({
  distribution,
  totalRoutes,
  title = "Grade Distribution",
  description,
  selectedGrade,
  onSelectGrade,
  itemName = "sector",
  asContainer = false,
}: GradeDistributionCardProps) => {
  const chartConfig = {
    count: {
      label: "Routes",
      color: "hsl(var(--chart-1))",
    },
  } satisfies ChartConfig;

  // Calculate the chart width based on the number of grades
  const chartWidth = useMemo(() => {
    const gradeCount = distribution.length;
    const pixelWidth = gradeCount * 40;
    return `${pixelWidth}px`;
  }, [distribution]);

  if (distribution.length === 0) {
    return null;
  }

  const averageGrade = distribution.length > 0 ? distribution[Math.floor(distribution.length / 2)].grade : "N/A";

  // Count of filtered routes if grade is selected
  const filteredRoutesCount = selectedGrade
    ? distribution.find((item) => item.grade === selectedGrade)?.count || 0
    : totalRoutes;

  const handleGradeSelection = (grade: string) => {
    const newSelectedGrade = selectedGrade === grade ? null : grade;
    onSelectGrade(newSelectedGrade);
  };

  const content = (
    <>
      <div className="text-muted-foreground mb-4 text-sm">
        Click on a bar to filter by grade {selectedGrade && `• ${selectedGrade} selected`}
      </div>
      <div className="flex w-full items-center justify-center overflow-x-auto">
        <GradeChart
          distribution={distribution}
          chartWidth={chartWidth}
          chartConfig={chartConfig}
          selectedGrade={selectedGrade}
          onSelectGrade={handleGradeSelection}
        />
      </div>
      {selectedGrade && (
        <div className="mt-4 flex items-center justify-center gap-2">
          <div className="text-sm font-medium">Filtered by grade:</div>
          <SelectedGradeBadge grade={selectedGrade} onClear={() => handleGradeSelection(selectedGrade)} />
        </div>
      )}
      <StatsFooter
        averageGrade={averageGrade}
        totalRoutes={totalRoutes}
        filteredCount={filteredRoutesCount}
        isFiltered={!!selectedGrade}
        itemName={itemName}
      />
    </>
  );

  if (asContainer) {
    return (
      <div className="mb-6 rounded-lg border p-4">
        <h3 className="mb-2 text-lg font-medium">{title}</h3>
        {content}
      </div>
    );
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <div>
          <CardTitle>{title}</CardTitle>
          <CardDescription>
            {selectedGrade
              ? `Showing routes with grade ${selectedGrade}`
              : description || `Climbing grades in this ${itemName}`}
          </CardDescription>
        </div>
      </CardHeader>
      <CardContent>{content}</CardContent>
    </Card>
  );
};

// Helper function to calculate grade distribution from routes
export const calculateGradeDistribution = (routes: { grade?: ClimbingGrade }[]) => {
  if (!routes || routes.length === 0) return [];

  const distribution = routes.reduce(
    (acc, route) => {
      if (route.grade) {
        const grade = formatClimbingGrade(route.grade);
        acc[grade] = (acc[grade] || 0) + 1;
      }
      return acc;
    },
    {} as Record<string, number>,
  );

  // Sort grades
  return Object.entries(distribution)
    .sort((a, b) => {
      // Extract numeric part and modifier for proper sorting
      const [gradeANum, gradeAMod] = a[0].split(/(\d+)(.*)/).filter(Boolean);
      const [gradeBNum, gradeBMod] = b[0].split(/(\d+)(.*)/).filter(Boolean);

      // Compare numeric values first
      const numA = parseInt(gradeANum);
      const numB = parseInt(gradeBNum);

      if (numA !== numB) return numA - numB;

      // If numeric values are equal, sort by modifier (+ comes after no modifier)
      if (gradeAMod.includes("+") && !gradeBMod.includes("+")) return 1;
      if (!gradeAMod.includes("+") && gradeBMod.includes("+")) return -1;

      return 0;
    })
    .map(([grade, count]) => ({
      grade,
      count,
    }));
};
