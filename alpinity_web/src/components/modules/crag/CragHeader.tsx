import { MapPin } from "lucide-react";

interface CragHeaderProps {
  name: string;
  description?: string | null;
  locationName?: string | null;
}

const CragHeader = ({ name, description, locationName }: CragHeaderProps) => {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="scroll-m-20 text-4xl font-extrabold tracking-tight lg:text-5xl">{name}</h1>
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
