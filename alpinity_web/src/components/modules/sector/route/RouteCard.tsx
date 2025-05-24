import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Label } from "@/components/ui/label";
import { GradeBadge, TypeBadge } from "@/components/ui/library/Badge";
import { SectorRouteDto } from "@/lib/api/types.gen";
import { formatClimbingCategoryType, formatRouteType } from "@/lib/utils/formatters";
import { Edit, MoreHorizontal, Trash2 } from "lucide-react";

interface RouteCardProps {
  route: SectorRouteDto;
  isSelected: boolean;
  onSelect: () => void;
  onAscentClick: () => void;
  canModify?: boolean;
  onEditRoute?: () => void;
  onDeleteRoute?: () => void;
}

const RouteCard = ({
  route,
  isSelected,
  onSelect,
  onAscentClick,
  canModify,
  onEditRoute,
  onDeleteRoute,
}: RouteCardProps) => {
  // Combine all types into a single array
  const allTypes = [
    ...(route.routeCategories?.climbTypes || []),
    ...(route.routeCategories?.rockTypes || []),
    ...(route.routeCategories?.holdTypes || []),
  ].filter(Boolean);

  return (
    <div
      className={`hover:bg-accent/50 flex cursor-pointer flex-col p-3 transition-all ${isSelected ? "bg-accent/80" : ""}`}
      onClick={onSelect}
    >
      <div className="flex items-center justify-between">
        <h4 className="font-medium">{route.name || "Unnamed Route"}</h4>
        {route.grade && <GradeBadge grade={route.grade} />}
      </div>

      {route.routeType && route.routeType.length > 0 && (
        <div className="mt-1 flex flex-col">
          <div className="text-muted-foreground flex gap-2 overflow-x-auto pb-1 text-xs whitespace-nowrap md:flex-wrap md:whitespace-normal">
            {route.routeType.map((type, index) => (
              <TypeBadge key={`routeType-${type}-${index}`} label={formatRouteType(type)} variant="primary" />
            ))}
          </div>
        </div>
      )}

      {allTypes.length > 0 || route.description ? (
        <div className="mt-1 flex flex-col">
          {allTypes.length > 0 && (
            <div className="text-muted-foreground flex gap-2 overflow-x-auto pb-1 text-xs whitespace-nowrap md:flex-wrap md:whitespace-normal">
              {allTypes.map((type, index) => (
                <TypeBadge key={`${type}-${index}`} label={formatClimbingCategoryType(type)} />
              ))}
            </div>
          )}

          {route.description && <p className="text-muted-foreground mt-1 line-clamp-1 text-xs">{route.description}</p>}
        </div>
      ) : null}

      <div className="mt-2 flex items-center justify-between">
        <div className="text-muted-foreground text-xs">
          {route.ascentsCount && route.ascentsCount > 0 ? (
            <Label
              className="bg-primary/20 hover:bg-primary/30 cursor-pointer rounded-full p-2 text-xs"
              onClick={(e) => {
                e.stopPropagation();
                onAscentClick();
              }}
            >
              {route.ascentsCount} {route.ascentsCount === 1 ? "ascent" : "ascents"}
            </Label>
          ) : null}
        </div>

        {canModify && (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="h-8 w-8" onClick={(e) => e.stopPropagation()}>
                <MoreHorizontal className="h-4 w-4" />
                <span className="sr-only">Route options</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation();
                  onEditRoute?.();
                }}
              >
                <Edit className="mr-2 h-4 w-4" />
                Edit Route
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={(e) => {
                  e.stopPropagation();
                  onDeleteRoute?.();
                }}
                className="text-destructive"
              >
                <Trash2 className="mr-2 h-4 w-4" />
                Delete Route
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        )}
      </div>
    </div>
  );
};

export default RouteCard;
