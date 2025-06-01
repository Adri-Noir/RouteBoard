import { LogAscentDialog } from "@/components/modules/route/log-ascent";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SectorDetailedDto, SectorRouteDto } from "@/lib/api/types.gen";
import { useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import AscentDialog from "./AscentDialog";
import RouteImage from "./RouteImage";
import RouteList from "./RouteList";

interface SectorRoutesProps {
  sector: SectorDetailedDto;
  canModify?: boolean;
  onEditRoute?: (routeId: string) => void;
  onDeleteRoute?: (routeId: string) => void;
}

const SectorRoutes = ({ sector, canModify, onEditRoute, onDeleteRoute }: SectorRoutesProps) => {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [selectedRouteId, setSelectedRouteId] = useState<string | undefined>(
    searchParams.get("routeId") || (sector.routes && sector.routes.length > 0 ? sector.routes[0].id : undefined),
  );
  const [ascentDialogOpen, setAscentDialogOpen] = useState(false);
  const [selectedAscentRouteId, setSelectedAscentRouteId] = useState<string | null>(null);
  const [logAscentDialogOpen, setLogAscentDialogOpen] = useState(false);
  const [selectedLogAscentRoute, setSelectedLogAscentRoute] = useState<SectorRouteDto | null>(null);

  const selectedRoute = sector.routes?.find((route) => route.id === selectedRouteId);

  useEffect(() => {
    if (sector.routes && sector.routes.length > 0) {
      if (!selectedRouteId) {
        setSelectedRouteId(sector.routes[0].id);
      } else if (!sector.routes.some((route) => route.id === selectedRouteId)) {
        setSelectedRouteId(sector.routes[0].id);
      }
    }
  }, [sector.routes, selectedRouteId]);

  // Update URL when selected route changes
  useEffect(() => {
    if (selectedRouteId) {
      const params = new URLSearchParams(searchParams.toString());
      params.set("sectorId", sector.id);
      params.set("routeId", selectedRouteId);
      router.replace(`?${params.toString()}`, { scroll: false });
    }
  }, [selectedRouteId, router, searchParams, sector.id]);

  if (!sector.routes || sector.routes.length === 0) {
    return null;
  }

  const handleAscentClick = (routeId: string) => {
    setSelectedAscentRouteId(routeId);
    setAscentDialogOpen(true);
  };

  const handleLogAscentClick = (routeId: string) => {
    const foundRoute = sector.routes?.find((r) => r.id === routeId);
    setSelectedLogAscentRoute(foundRoute || null);
    setLogAscentDialogOpen(true);
  };

  const routeName = sector.routes?.find((r) => r.id === selectedAscentRouteId)?.name ?? undefined;

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Routes</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <RouteImage selectedRoute={selectedRoute} key={selectedRoute?.id} />
            <RouteList
              routes={sector.routes}
              selectedRouteId={selectedRouteId}
              onRouteSelect={setSelectedRouteId}
              onAscentClick={handleAscentClick}
              onLogAscentClick={handleLogAscentClick}
              canModify={canModify}
              onEditRoute={onEditRoute}
              onDeleteRoute={onDeleteRoute}
            />
          </div>
        </CardContent>
      </Card>

      <AscentDialog
        open={ascentDialogOpen}
        onOpenChange={setAscentDialogOpen}
        routeId={selectedAscentRouteId}
        routeName={routeName}
      />

      <LogAscentDialog
        open={logAscentDialogOpen}
        onOpenChange={setLogAscentDialogOpen}
        route={selectedLogAscentRoute}
      />
    </>
  );
};

export default SectorRoutes;
