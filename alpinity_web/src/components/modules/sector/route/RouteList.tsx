import { SectorRouteDto } from "@/lib/api/types.gen";
import RouteCard from "./RouteCard";

interface RouteListProps {
  routes: SectorRouteDto[];
  selectedRouteId: string | undefined;
  onRouteSelect: (routeId: string) => void;
  onAscentClick: (routeId: string) => void;
}

const RouteList = ({ routes, selectedRouteId, onRouteSelect, onAscentClick }: RouteListProps) => {
  return (
    <div className="order-1 flex max-h-[75vh] flex-col overflow-y-auto lg:order-2">
      <div className="divide-y rounded-lg border">
        {routes.map((route) => (
          <RouteCard
            key={route.id}
            route={route}
            isSelected={selectedRouteId === route.id}
            onSelect={() => onRouteSelect(route.id)}
            onAscentClick={() => onAscentClick(route.id)}
          />
        ))}
      </div>
    </div>
  );
};

export default RouteList;
