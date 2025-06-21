import { Button } from "@/components/ui/button";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import Link from "next/link";

export const ARFeature = () => {
  return (
    <div className="py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 items-center gap-8 md:grid-cols-2">
          <div className="text-left">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">Augmented Reality Detection</h2>
            <p className="text-muted-foreground mt-4 text-xl">
              Simply point your camera at the crag – Alpinity draws the line of the route right on the rock, even
              offline.
            </p>
            <div className="mt-6">
              <Button variant="default">
                <Link href="/ar">Try AR Feature</Link>
              </Button>
            </div>
          </div>

          <div className="relative h-[600px] overflow-hidden">
            <ImageWithLoading
              src="/images/ar_feature.PNG"
              alt="AR Feature"
              fill
              className="rounded-lg object-scale-down"
              sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
              containerClassName="h-[600px]"
            />
          </div>
        </div>
      </div>
    </div>
  );
};
