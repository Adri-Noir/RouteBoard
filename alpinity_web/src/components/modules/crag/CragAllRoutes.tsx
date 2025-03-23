"use client";

import { calculateGradeDistribution, GradeDistributionCard } from "@/components/modules/charts/GradeDistributionChart";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { CragDetailedDto, RouteType, SectorDetailedDto, SectorRouteDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { MoreVertical, Search } from "lucide-react";
import { useMemo, useState } from "react";
import AscentDialog from "../sector/route/AscentDialog";

interface CragAllRoutesProps {
  crag: CragDetailedDto;
}

// Helper function to get the value for sorting
const getSortValue = (
  item: { route: SectorRouteDto; sectorName: string | null },
  sortKey: "name" | "grade" | "ascents" | "sector",
): string | number | null => {
  const { route, sectorName } = item;

  switch (sortKey) {
    case "name":
      return route.name || "";
    case "grade":
      // Using the raw grade value for sorting since it has a logical order
      return route.grade || null;
    case "ascents":
      return route.ascentsCount || 0;
    case "sector":
      return sectorName || "";
    default:
      return null;
  }
};

const CragAllRoutes = ({ crag }: CragAllRoutesProps) => {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedGrade, setSelectedGrade] = useState<string | null>(null);
  const [selectedRouteType, setSelectedRouteType] = useState<RouteType | null>(null);
  const [selectedSector, setSelectedSector] = useState<string | null>(null);
  const [sortBy, setSortBy] = useState<"name" | "grade" | "ascents" | "sector">("name");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc");
  const [ascentDialogOpen, setAscentDialogOpen] = useState(false);
  const [selectedAscentRouteId, setSelectedAscentRouteId] = useState<string | null>(null);

  // Get all routes from all sectors
  const allRoutes = useMemo(() => {
    const routes: { route: SectorRouteDto; sectorName: string | null }[] = [];

    crag.sectors?.forEach((sector: SectorDetailedDto) => {
      sector.routes?.forEach((route: SectorRouteDto) => {
        routes.push({
          route,
          sectorName: sector.name,
        });
      });
    });

    return routes;
  }, [crag.sectors]);

  // Get grade distribution for the chart
  const gradeDistribution = useMemo(() => {
    const routesForDistribution = allRoutes.map(({ route }) => route);
    return calculateGradeDistribution(routesForDistribution);
  }, [allRoutes]);

  // Get all unique route types for filtering
  const uniqueRouteTypes = useMemo(() => {
    const types = new Set<RouteType>();

    allRoutes.forEach(({ route }) => {
      route.routeType?.forEach((type) => {
        types.add(type);
      });
    });

    return Array.from(types).sort();
  }, [allRoutes]);

  // Filter and sort routes
  const filteredAndSortedRoutes = useMemo(() => {
    let result = [...allRoutes];

    // Apply filters
    if (searchTerm) {
      const lowerSearchTerm = searchTerm.toLowerCase();
      result = result.filter(
        ({ route }) =>
          route.name?.toLowerCase().includes(lowerSearchTerm) ||
          route.description?.toLowerCase().includes(lowerSearchTerm),
      );
    }

    if (selectedGrade) {
      result = result.filter(({ route }) => route.grade && formatClimbingGrade(route.grade) === selectedGrade);
    }

    if (selectedRouteType) {
      result = result.filter(({ route }) => route.routeType?.includes(selectedRouteType as RouteType));
    }

    // Only filter by sector if a specific sector is selected (null means show all sectors)
    if (selectedSector) {
      result = result.filter(({ sectorName }) => sectorName === selectedSector);
    }

    // Apply sorting
    result.sort((a, b) => {
      const aValue = getSortValue(a, sortBy);
      const bValue = getSortValue(b, sortBy);

      if (aValue === null && bValue === null) return 0;
      if (aValue === null) return 1;
      if (bValue === null) return -1;

      // String comparison for string values
      if (typeof aValue === "string" && typeof bValue === "string") {
        return sortDirection === "asc" ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue);
      }

      // Numeric comparison for numbers
      return sortDirection === "asc"
        ? (aValue as number) - (bValue as number)
        : (bValue as number) - (aValue as number);
    });

    return result;
  }, [allRoutes, searchTerm, selectedGrade, selectedRouteType, selectedSector, sortBy, sortDirection]);

  const handleSort = (column: "name" | "grade" | "ascents" | "sector") => {
    if (sortBy === column) {
      // Toggle sort direction if clicking the same column
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      // Set new sort column and default to ascending
      setSortBy(column);
      setSortDirection("asc");
    }
  };

  const handleAscentClick = (routeId: string) => {
    setSelectedAscentRouteId(routeId);
    setAscentDialogOpen(true);
  };

  const selectedRouteName = useMemo(() => {
    if (!selectedAscentRouteId) return undefined;
    const foundRoute = allRoutes.find(({ route }) => route.id === selectedAscentRouteId);
    return foundRoute?.route.name || undefined;
  }, [selectedAscentRouteId, allRoutes]);

  // Get all unique sector names for filter
  const uniqueSectors = useMemo(() => {
    const sectors = new Set<string>();

    crag.sectors?.forEach((sector: SectorDetailedDto) => {
      if (sector.name) {
        sectors.add(sector.name);
      }
    });

    return Array.from(sectors).sort();
  }, [crag.sectors]);

  if (!allRoutes.length) {
    return <div className="text-muted-foreground py-4 text-center">No routes available in this crag.</div>;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>All Routes</CardTitle>
      </CardHeader>
      <CardContent>
        {/* Interactive Grade Distribution Chart */}
        {gradeDistribution.length > 0 && (
          <GradeDistributionCard
            distribution={gradeDistribution}
            totalRoutes={allRoutes.length}
            selectedGrade={selectedGrade}
            onSelectGrade={(grade) => setSelectedGrade(grade)}
            title="Grade Distribution"
            description="Climbing grades in this crag"
            itemName="crag"
            asContainer={true}
          />
        )}

        {/* Filter Controls */}
        <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
          {/* Search */}
          <div className="relative">
            <Search className="text-muted-foreground absolute top-2.5 left-2.5 h-4 w-4" />
            <Input
              placeholder="Search routes..."
              className="pl-8"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          {/* Route Type Filter */}
          <Select
            value={selectedRouteType || "all_types"}
            onValueChange={(value) => setSelectedRouteType(value === "all_types" ? null : (value as RouteType))}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="Route Type" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all_types">All Types</SelectItem>
              {uniqueRouteTypes.map((type) => (
                <SelectItem key={type} value={type}>
                  {type}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {/* Sector Filter */}
          <Select
            value={selectedSector || "all_sectors"}
            onValueChange={(value) => setSelectedSector(value === "all_sectors" ? null : value)}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="Sector" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all_sectors">All Sectors</SelectItem>
              {uniqueSectors.map((sector) => (
                <SelectItem key={sector} value={sector}>
                  {sector}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {/* Reset Filters */}
          <Button
            variant="outline"
            onClick={() => {
              setSearchTerm("");
              setSelectedGrade(null);
              setSelectedRouteType(null);
              setSelectedSector(null);
            }}
          >
            Reset Filters
          </Button>
        </div>

        {/* Routes Table */}
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
              {filteredAndSortedRoutes.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="h-24 text-center">
                    No routes found with the current filters
                  </TableCell>
                </TableRow>
              ) : (
                filteredAndSortedRoutes.map(({ route, sectorName }) => (
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
                            {type}
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
      </CardContent>

      {/* Ascent Dialog */}
      <AscentDialog
        open={ascentDialogOpen}
        onOpenChange={setAscentDialogOpen}
        routeId={selectedAscentRouteId}
        routeName={selectedRouteName}
      />
    </Card>
  );
};

export default CragAllRoutes;
