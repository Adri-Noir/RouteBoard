"use client";

import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import type { RouteTypeAscentCountDto } from "@/lib/api/types.gen";

interface ProfileAscentTypeTableProps {
  data: RouteTypeAscentCountDto[];
  selectedRouteType?: string | null;
  onSelectRouteType?: (routeType: string | null) => void;
}

export function ProfileAscentTypeTable({ data, selectedRouteType, onSelectRouteType }: ProfileAscentTypeTableProps) {
  const ascentTypes = ["Onsight", "Flash", "Redpoint", "Aid"];

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Route Type</TableHead>
          {ascentTypes.map((type) => (
            <TableHead key={type}>{type}</TableHead>
          ))}
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((item) => {
          const counts: Record<string, number> = {
            Onsight: 0,
            Flash: 0,
            Redpoint: 0,
            Aid: 0,
          };
          item.ascentCount?.forEach((ac) => {
            if (ac.ascentType) {
              counts[ac.ascentType] = ac.count ?? 0;
            }
          });
          const typeKey = item.routeType || "Unknown";
          const isSelected = selectedRouteType === item.routeType;
          return (
            <TableRow
              key={typeKey}
              className={isSelected ? "bg-muted" : undefined}
              onClick={() => onSelectRouteType?.(item.routeType ?? null)}
              style={{ cursor: onSelectRouteType ? "pointer" : undefined }}
            >
              <TableCell>{typeKey}</TableCell>
              {ascentTypes.map((type) => (
                <TableCell key={type}>{counts[type] ?? 0}</TableCell>
              ))}
            </TableRow>
          );
        })}
      </TableBody>
    </Table>
  );
}
