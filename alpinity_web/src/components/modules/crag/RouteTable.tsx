"use client";

import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { GradeBadge, TypeBadge } from "@/components/ui/library/Badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { SectorRouteDto } from "@/lib/api/types.gen";
import { formatRouteType } from "@/lib/utils/formatters";
import { Edit, MoreVertical, Plus, Trash2 } from "lucide-react";

interface RouteTableProps {
  routes: { route: SectorRouteDto; sectorName: string | null; sectorId: string }[];
  sortBy: "name" | "grade" | "ascents" | "sector";
  sortDirection: "asc" | "desc";
  handleSort: (column: "name" | "grade" | "ascents" | "sector") => void;
  handleAscentClick: (routeId: string) => void;
  onViewAscents?: (routeId: string) => void;
  canModify?: boolean;
  onEditRoute?: (routeId: string) => void;
  onDeleteRoute?: (routeId: string) => void;
  onSelectRoute?: (sectorId: string, routeId: string) => void;
}

const RouteTable = ({
  routes,
  sortBy,
  sortDirection,
  handleSort,
  handleAscentClick,
  onViewAscents,
  canModify,
  onEditRoute,
  onDeleteRoute,
  onSelectRoute,
}: RouteTableProps) => {
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
            <TableHead className="cursor-pointer text-center" onClick={() => handleSort("ascents")}>
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
            routes.map(({ route, sectorName, sectorId }) => (
              <TableRow key={route.id} className={onSelectRoute ? "hover:bg-muted" : undefined}>
                <TableCell className="font-medium">
                  <span
                    className="cursor-pointer underline"
                    onClick={(e) => {
                      e.stopPropagation();
                      onSelectRoute?.(sectorId, route.id);
                    }}
                  >
                    {route.name || "Unnamed Route"}
                  </span>
                </TableCell>
                <TableCell>{route.grade ? <GradeBadge grade={route.grade} /> : "-"}</TableCell>
                <TableCell>
                  <div className="flex flex-wrap gap-1">
                    {route.routeType?.map((type, index) => (
                      <TypeBadge key={`${route.id}-type-${index}`} label={formatRouteType(type)} variant="primary" />
                    ))}
                  </div>
                </TableCell>
                <TableCell>{sectorName || "-"}</TableCell>
                <TableCell className="text-center">
                  {route.ascentsCount && route.ascentsCount > 0 && onViewAscents ? (
                    <Button
                      variant="link"
                      className="text-foreground underline"
                      onClick={() => onViewAscents(route.id)}
                    >
                      {route.ascentsCount}
                    </Button>
                  ) : (
                    <span className="text-center">{route.ascentsCount || 0}</span>
                  )}
                </TableCell>
                <TableCell className="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon" className="h-8 w-8">
                        <MoreVertical className="h-4 w-4" />
                        <span className="sr-only">Open menu</span>
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem onClick={() => handleAscentClick(route.id)}>
                        <Plus className="mr-2 h-4 w-4" />
                        Log Ascent
                      </DropdownMenuItem>
                      {canModify && (
                        <>
                          <DropdownMenuItem onClick={() => onEditRoute?.(route.id)}>
                            <Edit className="mr-2 h-4 w-4" />
                            Edit Route
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => onDeleteRoute?.(route.id)} className="text-destructive">
                            <Trash2 className="mr-2 h-4 w-4" />
                            Delete Route
                          </DropdownMenuItem>
                        </>
                      )}
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
