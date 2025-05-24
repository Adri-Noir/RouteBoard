import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Edit, MapPin, MoreHorizontal, Plus, Trash2 } from "lucide-react";

interface CragHeaderProps {
  name: string;
  description?: string | null;
  locationName?: string | null;
  canModify?: boolean;
  onEditCrag?: () => void;
  onCreateSector?: () => void;
  onDeleteCrag?: () => void;
}

const CragHeader = ({
  name,
  description,
  locationName,
  canModify,
  onEditCrag,
  onCreateSector,
  onDeleteCrag,
}: CragHeaderProps) => {
  return (
    <div className="space-y-4 p-4">
      <div>
        <div className="flex items-center justify-between">
          <h1 className="scroll-m-20 text-4xl font-extrabold tracking-tight lg:text-5xl">{name}</h1>
          {canModify && (
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="icon">
                  <MoreHorizontal className="h-4 w-4" />
                  <span className="sr-only">More options</span>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={onEditCrag}>
                  <Edit className="mr-2 h-4 w-4" />
                  Edit Crag
                </DropdownMenuItem>
                <DropdownMenuItem onClick={onCreateSector}>
                  <Plus className="mr-2 h-4 w-4" />
                  Create Sector
                </DropdownMenuItem>
                <DropdownMenuItem onClick={onDeleteCrag} className="text-destructive">
                  <Trash2 className="mr-2 h-4 w-4" />
                  Delete Crag
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          )}
        </div>
        {locationName && (
          <div className="text-muted-foreground mt-1 flex items-center gap-1">
            <MapPin className="h-4 w-4" />
            <span>{locationName}</span>
          </div>
        )}
      </div>
      {description && (
        <div className="leading-7 [&:not(:first-child)]:mt-6">
          <p>{description}</p>
        </div>
      )}
    </div>
  );
};

export default CragHeader;
