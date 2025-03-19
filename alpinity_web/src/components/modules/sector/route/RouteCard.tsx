import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { SectorRouteDto } from "@/lib/api/types.gen";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { ChevronRight } from "lucide-react";
import Link from "next/link";

interface RouteCardProps {
  route: SectorRouteDto;
  isSelected: boolean;
  onSelect: () => void;
  onAscentClick: () => void;
}

const RouteCard = ({ route, isSelected, onSelect, onAscentClick }: RouteCardProps) => {
  return (
    <div
      className={`hover:bg-accent/50 flex cursor-pointer flex-col p-3 transition-all ${isSelected ? "bg-accent/80" : ""}`}
      onClick={onSelect}
    >
      <div className="flex items-center justify-between">
        <h4 className="font-medium">{route.name || "Unnamed Route"}</h4>
        {route.grade && (
          <span className="bg-primary/10 text-primary rounded-md px-2 py-1 text-xs font-semibold">
            {formatClimbingGrade(route.grade)}
          </span>
        )}
      </div>

      {(route.routeType && route.routeType.length > 0) || route.description ? (
        <div className="mt-1 flex flex-col">
          {route.routeType && route.routeType.length > 0 && (
            <span className="text-muted-foreground text-xs">{route.routeType.join(", ")}</span>
          )}

          {route.description && <p className="text-muted-foreground mt-1 line-clamp-1 text-xs">{route.description}</p>}
        </div>
      ) : null}

      <div className="mt-2 flex items-center justify-between">
        <div className="text-muted-foreground text-xs">
          {route.ascentsCount && route.ascentsCount > 0 && (
            <Label
              className="bg-primary/20 hover:bg-primary/30 cursor-pointer rounded-full p-2 text-xs"
              onClick={(e) => {
                e.stopPropagation();
                onAscentClick();
              }}
            >
              {route.ascentsCount} {route.ascentsCount === 1 ? "ascent" : "ascents"}
            </Label>
          )}
        </div>
        <Button asChild size="sm" variant="ghost" className="h-6 px-2 text-xs">
          <Link href={`/route/${route.id}`}>
            Details
            <ChevronRight className="ml-1 h-3 w-3" />
          </Link>
        </Button>
      </div>
    </div>
  );
};

export default RouteCard;
