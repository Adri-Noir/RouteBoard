import { Card } from "@/components/ui/card";
import { ExploreDto } from "@/lib/api/types.gen";
import { MapPin } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

interface ExploreCardProps {
  data: ExploreDto;
}

export function ExploreCard({ data }: ExploreCardProps) {
  return (
    <Link href={`/crag/${data.cragId}`}>
      <Card className="group overflow-hidden p-0 transition-all hover:scale-102 hover:shadow-md">
        <div className="relative h-60 w-full">
          {data.photo?.url ? (
            <Image
              src={data.photo.url}
              alt={data.cragName || "Crag image"}
              className="object-cover"
              fill
              sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            />
          ) : (
            <div className="bg-gray flex h-full w-full items-center justify-center">
              <span className="text-muted-foreground">No image available</span>
            </div>
          )}

          {/* Gradient overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/75 to-black/45" />

          {/* Information overlay */}
          <div className="text-foreground absolute right-0 bottom-0 left-0 p-4">
            <h3 className="text-xl font-bold text-white transition-colors">{data.cragName || "Unnamed Crag"}</h3>

            <div className="flex items-center gap-1 text-sm text-white">
              <MapPin className="h-3 w-3" />
              <span>{data.locationName || "Unknown location"}</span>
            </div>

            <div className="mt-2 flex gap-4 text-sm">
              <div>
                <span className="font-medium text-white">{data.sectorsCount || 0}</span>{" "}
                <span className="text-white">sectors</span>
              </div>
              <div>
                <span className="font-medium text-white">{data.routesCount || 0}</span>{" "}
                <span className="text-white">routes</span>
              </div>
              <div>
                <span className="font-medium text-white">{data.ascentsCount || 0}</span>{" "}
                <span className="text-white">ascents</span>
              </div>
            </div>
          </div>
        </div>
      </Card>
    </Link>
  );
}
