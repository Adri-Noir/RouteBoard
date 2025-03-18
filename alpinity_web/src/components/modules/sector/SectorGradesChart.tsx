import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartConfig, ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart";
import { SectorDetailedDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { TrendingUp } from "lucide-react";
import { useMemo } from "react";
import { Bar, BarChart, CartesianGrid, XAxis } from "recharts";

interface SectorGradesChartProps {
  sector: SectorDetailedDto;
}

const SectorGradesChart = ({ sector }: SectorGradesChartProps) => {
  // Calculate grade distribution
  const gradeDistribution = useMemo(() => {
    if (!sector.routes || sector.routes.length === 0) return [];

    const distribution = sector.routes.reduce(
      (acc, route) => {
        if (route.grade) {
          const grade = formatClimbingGrade(route.grade);
          acc[grade] = (acc[grade] || 0) + 1;
        }
        return acc;
      },
      {} as Record<string, number>,
    );

    // Sort grades (similar to the parent component)
    return Object.entries(distribution)
      .sort((a, b) => {
        const gradeA = a[0].replace("+", "");
        const gradeB = b[0].replace("+", "");
        const numA = parseInt(gradeA);
        const numB = parseInt(gradeB);
        if (numA !== numB) return numA - numB;
        return a[0].includes("+") ? 1 : -1;
      })
      .map(([grade, count]) => ({
        grade,
        count,
      }));
  }, [sector.routes]);

  const chartConfig = {
    count: {
      label: "Routes",
      color: "hsl(var(--chart-1))",
    },
  } satisfies ChartConfig;

  if (gradeDistribution.length === 0) {
    return null;
  }

  const totalRoutes = sector.routes?.length || 0;
  const averageGrade =
    gradeDistribution.length > 0 ? gradeDistribution[Math.floor(gradeDistribution.length / 2)].grade : "N/A";

  return (
    <Card>
      <CardHeader>
        <CardTitle>Grade Distribution</CardTitle>
        <CardDescription>Climbing grades in this sector</CardDescription>
      </CardHeader>
      <CardContent>
        <ChartContainer config={chartConfig} className="h-[200px]">
          <BarChart accessibilityLayer data={gradeDistribution}>
            <CartesianGrid vertical={false} />
            <XAxis dataKey="grade" tickLine={false} tickMargin={10} axisLine={false} />
            <ChartTooltip cursor={false} content={<ChartTooltipContent hideLabel />} />
            <Bar dataKey="count" fill="var(--color-count)" radius={8} />
          </BarChart>
        </ChartContainer>
      </CardContent>
      <CardFooter className="flex-col items-start gap-2 text-sm">
        <div className="flex gap-2 leading-none font-medium">
          Median grade: {averageGrade} <TrendingUp className="h-4 w-4" />
        </div>
        <div className="text-muted-foreground leading-none">
          Showing distribution for {totalRoutes} routes in this sector
        </div>
      </CardFooter>
    </Card>
  );
};

export default SectorGradesChart;
