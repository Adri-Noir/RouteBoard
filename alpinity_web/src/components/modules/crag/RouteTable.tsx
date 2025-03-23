"use client";

import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { SectorRouteDto } from "@/lib/api/types.gen";
import { formatClimbingGrade, formatRouteType } from "@/lib/utils/formatters";
import { MoreVertical } from "lucide-react";

interface RouteTableProps {
  routes: { route: SectorRouteDto; sectorName: string | null }[];
  sortBy: "name" | "grade" | "ascents" | "sector";
  sortDirection: "asc" | "desc";
  handleSort: (column: "name" | "grade" | "ascents" | "sector") => void;
  handleAscentClick: (routeId: string) => void;
}

const RouteTable = ({ routes, sortBy, sortDirection, handleSort, handleAscentClick }: RouteTableProps) => {
  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="cursor-pointer" onClick={() => handleSort("name")}>
              Name {sortBy === "name" && (sortDirection === "asc" ? "↑" : "↓")}
            </TableHead>
            <TableHead className="cursor-pointer" onClick={() => handleSort("grade")}>
              Grade {sortBy === "grade" && (sortDirection === "asc" ? "↑" : "↓")}
            </TableHead>
            <TableHead>Type</TableHead>
            <TableHead className="cursor-pointer" onClick={() => handleSort("sector")}>
              Sector {sortBy === "sector" && (sortDirection === "asc" ? "↑" : "↓")}
            </TableHead>
            <TableHead className="cursor-pointer text-right" onClick={() => handleSort("ascents")}>
              Ascents {sortBy === "ascents" && (sortDirection === "asc" ? "↑" : "↓")}
            </TableHead>
            <TableHead className="text-right">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {routes.length === 0 ? (
            <TableRow>
              <TableCell colSpan={6} className="h-24 text-center">
                No routes found with the current filters
              </TableCell>
            </TableRow>
          ) : (
            routes.map(({ route, sectorName }) => (
              <TableRow key={route.id}>
                <TableCell className="font-medium">{route.name || "Unnamed Route"}</TableCell>
                <TableCell>
                  {route.grade ? (
                    <span className="bg-primary/10 text-primary rounded-md px-2 py-1 text-xs font-semibold">
                      {formatClimbingGrade(route.grade)}
                    </span>
                  ) : (
                    "-"
                  )}
                </TableCell>
                <TableCell>
                  <div className="flex flex-wrap gap-1">
                    {route.routeType?.map((type, index) => (
                      <span
                        key={`${route.id}-type-${index}`}
                        className="bg-primary/10 text-primary inline-block rounded-full px-2 py-0.5 text-xs font-medium"
                      >
                        {formatRouteType(type)}
                      </span>
                    ))}
                  </div>
                </TableCell>
                <TableCell>{sectorName || "-"}</TableCell>
                <TableCell className="text-right">{route.ascentsCount || 0}</TableCell>
                <TableCell className="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon" className="h-8 w-8">
                        <MoreVertical className="h-4 w-4" />
                        <span className="sr-only">Open menu</span>
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem onClick={() => handleAscentClick(route.id)}>Log Ascent</DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))
          )}
        </TableBody>
      </Table>
    </div>
  );
};

export default RouteTable;
