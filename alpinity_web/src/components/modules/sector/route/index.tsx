import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SectorDetailedDto } from "@/lib/api/types.gen";
import { useState } from "react";
import AscentDialog from "./AscentDialog";
import RouteImage from "./RouteImage";
import RouteList from "./RouteList";

interface SectorRoutesProps {
  sector: SectorDetailedDto;
}

const SectorRoutes = ({ sector }: SectorRoutesProps) => {
  const [selectedRouteId, setSelectedRouteId] = useState<string | undefined>(
    sector.routes && sector.routes.length > 0 ? sector.routes[0].id : undefined,
  );
  const [ascentDialogOpen, setAscentDialogOpen] = useState(false);
  const [selectedAscentRouteId, setSelectedAscentRouteId] = useState<string | null>(null);

  const selectedRoute = sector.routes?.find((route) => route.id === selectedRouteId);

  if (!sector.routes || sector.routes.length === 0) {
    return null;
  }

  const handleAscentClick = (routeId: string) => {
    setSelectedAscentRouteId(routeId);
    setAscentDialogOpen(true);
  };

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Routes</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <RouteImage selectedRoute={selectedRoute} />
            <RouteList
              routes={sector.routes}
              selectedRouteId={selectedRouteId}
              onRouteSelect={setSelectedRouteId}
              onAscentClick={handleAscentClick}
            />
          </div>
        </CardContent>
      </Card>

      <AscentDialog
        open={ascentDialogOpen}
        onOpenChange={setAscentDialogOpen}
        routeId={selectedAscentRouteId}
        routeName={sector.routes?.find((r) => r.id === selectedAscentRouteId)?.name}
      />
    </>
  );
};

export default SectorRoutes;
