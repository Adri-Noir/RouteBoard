"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { RouteType } from "@/lib/api/types.gen";
import { formatRouteType } from "@/lib/utils/formatters";
import { Search } from "lucide-react";

interface RouteFiltersProps {
  searchTerm: string;
  setSearchTerm: (value: string) => void;
  selectedRouteType: RouteType | null;
  setSelectedRouteType: (value: RouteType | null) => void;
  selectedSector: string | null;
  setSelectedSector: (value: string | null) => void;
  uniqueRouteTypes: RouteType[];
  uniqueSectors: string[];
  resetFilters: () => void;
}

const RouteFilters = ({
  searchTerm,
  setSearchTerm,
  selectedRouteType,
  setSelectedRouteType,
  selectedSector,
  setSelectedSector,
  uniqueRouteTypes,
  uniqueSectors,
  resetFilters,
}: RouteFiltersProps) => {
  return (
    <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
      {/* Search */}
      <div className="relative">
        <Search className="text-muted-foreground absolute top-2.5 left-2.5 h-4 w-4" />
        <Input
          placeholder="Search routes..."
          className="pl-8"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              (e.target as HTMLInputElement).blur();
            }
          }}
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
              {formatRouteType(type)}
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
      <Button variant="outline" onClick={resetFilters}>
        Reset Filters
      </Button>
    </div>
  );
};

export default RouteFilters;
