"use client";

import { calculateGradeDistribution, GradeDistributionCard } from "@/components/modules/charts/GradeDistributionChart";
import { LogAscentDialog } from "@/components/modules/route/log-ascent";
import AscentDialog from "@/components/modules/sector/route/AscentDialog";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { CragDetailedDto, RouteType, SectorDetailedDto, SectorRouteDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { useMemo, useState } from "react";
import RouteFilters from "./RouteFilters";
import RouteTable from "./RouteTable";

interface CragAllRoutesProps {
  crag: CragDetailedDto;
  onEditRoute?: (routeId: string) => void;
  onDeleteRoute?: (routeId: string) => void;
  onSelectRoute?: (sectorId: string, routeId: string) => void;
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

const CragAllRoutes = ({ crag, onEditRoute, onDeleteRoute, onSelectRoute }: CragAllRoutesProps) => {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedGrade, setSelectedGrade] = useState<string | null>(null);
  const [selectedRouteType, setSelectedRouteType] = useState<RouteType | null>(null);
  const [selectedSector, setSelectedSector] = useState<string | null>(null);
  const [sortBy, setSortBy] = useState<"name" | "grade" | "ascents" | "sector">("name");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc");
  const [logAscentDialogOpen, setLogAscentDialogOpen] = useState(false);
  const [selectedLogAscentRoute, setSelectedLogAscentRoute] = useState<SectorRouteDto | null>(null);
  const [ascentDialogOpen, setAscentDialogOpen] = useState(false);
  const [selectedAscentRouteId, setSelectedAscentRouteId] = useState<string | null>(null);

  // Get all routes from all sectors
  const allRoutes = useMemo(() => {
    const routes: { route: SectorRouteDto; sectorName: string | null; sectorId: string }[] = [];

    crag.sectors?.forEach((sector: SectorDetailedDto) => {
      sector.routes?.forEach((route: SectorRouteDto) => {
        routes.push({
          route,
          sectorName: sector.name,
          sectorId: sector.id,
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
    const foundRoute = allRoutes.find(({ route }) => route.id === routeId)?.route;
    setSelectedLogAscentRoute(foundRoute || null);
    setLogAscentDialogOpen(true);
  };

  const handleViewAscents = (routeId: string) => {
    setSelectedAscentRouteId(routeId);
    setAscentDialogOpen(true);
  };

  const selectedAscentRouteName = useMemo(() => {
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

  // Reset all filters
  const resetFilters = () => {
    setSearchTerm("");
    setSelectedGrade(null);
    setSelectedRouteType(null);
    setSelectedSector(null);
  };

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
        <RouteFilters
          searchTerm={searchTerm}
          setSearchTerm={setSearchTerm}
          selectedRouteType={selectedRouteType}
          setSelectedRouteType={setSelectedRouteType}
          selectedSector={selectedSector}
          setSelectedSector={setSelectedSector}
          uniqueRouteTypes={uniqueRouteTypes}
          uniqueSectors={uniqueSectors}
          resetFilters={resetFilters}
        />

        {/* Routes Table */}
        <RouteTable
          routes={filteredAndSortedRoutes}
          sortBy={sortBy}
          sortDirection={sortDirection}
          handleSort={handleSort}
          handleAscentClick={handleAscentClick}
          onViewAscents={handleViewAscents}
          canModify={crag.canModify}
          onEditRoute={onEditRoute}
          onDeleteRoute={onDeleteRoute}
          onSelectRoute={onSelectRoute}
        />
      </CardContent>

      {/* View Ascents Dialog */}
      <AscentDialog
        open={ascentDialogOpen}
        onOpenChange={setAscentDialogOpen}
        routeId={selectedAscentRouteId}
        routeName={selectedAscentRouteName}
      />

      {/* Log Ascent Dialog */}
      <LogAscentDialog
        open={logAscentDialogOpen}
        onOpenChange={setLogAscentDialogOpen}
        route={selectedLogAscentRoute}
      />
    </Card>
  );
};

export default CragAllRoutes;
