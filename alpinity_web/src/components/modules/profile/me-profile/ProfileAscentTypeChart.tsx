"use client";

import { ChartConfig, ChartContainer } from "@/components/ui/chart";
import type { RouteType, RouteTypeAscentCountDto } from "@/lib/api/types.gen";
import { formatRouteType } from "@/lib/utils/formatters";
import { useMemo } from "react";
import { Bar, BarChart, CartesianGrid, Cell, Legend, Tooltip, XAxis } from "recharts";

interface ProfileAscentTypeChartProps {
  data: RouteTypeAscentCountDto[];
  onSelectRouteType?: (routeType: string | null) => void;
}

export function ProfileAscentTypeChart({ data, onSelectRouteType }: ProfileAscentTypeChartProps) {
  const ascentTypes = ["Onsight", "Flash", "Redpoint", "Aid"];

  const ascentTypeColors = {
    Onsight: "#10b981",
    Flash: "#3b82f6",
    Redpoint: "#f59e0b",
    Aid: "#ef4444",
  };

  const chartData = data.map((item) => {
    const row: Record<string, string | number> = {
      routeType: formatRouteType(item.routeType as RouteType) || "Unknown",
      originalRouteType: item.routeType || "Unknown",
    };
    item.ascentCount?.forEach((ac) => {
      if (ac.ascentType) {
        row[ac.ascentType] = ac.count ?? 0;
      }
    });
    return row;
  });

  const config: ChartConfig = {
    Onsight: { label: "Onsight", color: "#10b981" },
    Flash: { label: "Flash", color: "#3b82f6" },
    Redpoint: { label: "Redpoint", color: "#f59e0b" },
    Aid: { label: "Aid", color: "#ef4444" },
  };

  // Calculate the chart width based on the number of route types and bars
  const chartWidth = useMemo(() => {
    const routeTypeCount = chartData.length;
    const barWidth = 80; // Width per route type group
    const pixelWidth = Math.max(routeTypeCount * barWidth, 400); // Minimum width of 400px
    return `${pixelWidth}px`;
  }, [chartData]);

  if (chartData.length === 0) {
    return <p className="text-muted-foreground">No ascent data to display.</p>;
  }

  return (
    <div className="flex w-full items-center justify-center overflow-x-auto">
      <ChartContainer
        config={config}
        className="h-[300px]"
        style={{
          width: chartWidth,
        }}
      >
        <BarChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" horizontal={false} vertical={false} />
          <XAxis dataKey="routeType" tickLine={false} tickMargin={10} axisLine={false} />
          <Tooltip />
          <Legend />
          {ascentTypes.map((type) => (
            <Bar
              key={type}
              dataKey={type}
              stackId="a"
              cursor={onSelectRouteType ? "pointer" : undefined}
              onClick={(data) => onSelectRouteType?.(data.payload.originalRouteType ?? null)}
              fill={ascentTypeColors[type as keyof typeof ascentTypeColors]}
            >
              {chartData.map((entry, index) => (
                <Cell key={`cell-${type}-${index}`} fill={ascentTypeColors[type as keyof typeof ascentTypeColors]} />
              ))}
            </Bar>
          ))}
        </BarChart>
      </ChartContainer>
    </div>
  );
}
