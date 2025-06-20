import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { GradeBadge, TypeBadge } from "@/components/ui/library/Badge";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { getRouteAscentsByIdOptions } from "@/lib/api/@tanstack/react-query.gen";
import { AscentDto } from "@/lib/api/types.gen";
import { formatClimbType, formatHoldType, formatRockType } from "@/lib/utils/formatters";
import { useQuery } from "@tanstack/react-query";
import { CalendarIcon, Clock, Loader2, Star } from "lucide-react";

interface AscentDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  routeId: string | null;
  routeName: string | undefined;
}

const AscentDialog = ({ open, onOpenChange, routeId, routeName }: AscentDialogProps) => {
  const { data: ascents = [], isLoading } = useQuery({
    ...getRouteAscentsByIdOptions({
      path: { id: routeId || "" },
    }),
    enabled: !!routeId && open,
    refetchOnWindowFocus: false,
  });

  const formatAscentDate = (dateStr: string | null | undefined) => {
    if (!dateStr) return "Unknown date";
    const date = new Date(dateStr);
    return date.toLocaleDateString();
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-xl">
        <DialogHeader>
          <DialogTitle>
            Route Ascents
            {routeName && <span className="text-muted-foreground ml-2 font-normal">({routeName})</span>}
          </DialogTitle>
        </DialogHeader>
        <div className="max-h-[60vh] overflow-y-auto pr-1">
          {isLoading ? (
            <div className="flex justify-center py-8">
              <Loader2 className="text-muted-foreground h-6 w-6 animate-spin" />
            </div>
          ) : ascents.length === 0 ? (
            <p className="text-muted-foreground py-8 text-center">No ascents recorded yet.</p>
          ) : (
            <div className="space-y-3">
              {ascents.map((ascent: AscentDto) => (
                <div key={ascent.id} className="rounded-lg border p-3">
                  <div className="mb-2 flex items-center gap-3">
                    {ascent.userProfilePhoto?.url ? (
                      <ImageWithLoading
                        src={ascent.userProfilePhoto.url}
                        alt={ascent.username || "Climber"}
                        fill
                        className="rounded-full object-cover"
                        loadingSize="tiny"
                        containerClassName="w-10 h-10 rounded-full "
                      />
                    ) : (
                      <div className="bg-muted flex h-10 w-10 items-center justify-center rounded-full">
                        <span className="text-xs">{ascent.username?.charAt(0)?.toUpperCase() || "?"}</span>
                      </div>
                    )}
                    <div>
                      <h4 className="font-medium">{ascent.username || "Anonymous"}</h4>
                      <span className="bg-primary/10 text-primary rounded-md px-2 py-0.5 text-xs">
                        {ascent.ascentType || "Unknown"}
                      </span>
                    </div>
                  </div>

                  <div className="mt-3 grid grid-cols-1 gap-3 sm:grid-cols-2">
                    <div className="text-muted-foreground flex items-center gap-2 text-sm">
                      <CalendarIcon className="h-4 w-4" />
                      <span>{formatAscentDate(ascent.ascentDate)}</span>
                    </div>

                    {ascent.proposedGrade && (
                      <div className="text-muted-foreground flex items-center gap-2 text-sm">
                        <span>Proposed Grade:</span>
                        <GradeBadge grade={ascent.proposedGrade} className="text-xs" />
                      </div>
                    )}

                    {ascent.rating && ascent.rating > 0 && (
                      <div className="flex items-center gap-1 text-sm">
                        {Array.from({ length: 5 }).map((_, index) => (
                          <Star
                            key={`star-${routeId}-${index}`}
                            className={`h-4 w-4 ${index < (ascent.rating ?? 0) ? "fill-yellow-500 text-yellow-500" : "text-gray-300"}`}
                          />
                        ))}
                      </div>
                    )}

                    {ascent.numberOfAttempts && (
                      <div className="text-muted-foreground flex items-center gap-2 text-sm">
                        <Clock className="h-4 w-4" />
                        <span>{ascent.numberOfAttempts} attempts</span>
                      </div>
                    )}
                  </div>

                  {ascent.notes && (
                    <div className="mt-3 text-sm">
                      <p className="text-muted-foreground">{ascent.notes}</p>
                    </div>
                  )}

                  <div className="mt-3 flex flex-wrap gap-1">
                    {ascent.climbTypes &&
                      ascent.climbTypes.length > 0 &&
                      ascent.climbTypes.map((type) => <TypeBadge key={type} label={formatClimbType(type)} />)}

                    {ascent.rockTypes &&
                      ascent.rockTypes.length > 0 &&
                      ascent.rockTypes.map((type) => <TypeBadge key={type} label={formatRockType(type)} />)}

                    {ascent.holdTypes &&
                      ascent.holdTypes.length > 0 &&
                      ascent.holdTypes.map((type) => <TypeBadge key={type} label={formatHoldType(type)} />)}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default AscentDialog;
