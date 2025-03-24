import { ExploreList } from "@/components/modules/explore/ExploreList";
import { MapGlobe } from "@/components/modules/explore/MapGlobe";

export default function ExplorePage() {
  return (
    <div className="container mx-auto space-y-8 px-4 py-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight">Explore</h1>
        <p className="text-muted-foreground mt-2">Discover climbing locations, sectors, and routes around the world</p>
      </div>

      <div className="space-y-8">
        <section>
          <h2 className="mb-4 text-2xl font-semibold">Map</h2>
          <MapGlobe />
        </section>

        <section>
          <h2 className="mb-4 text-2xl font-semibold">Popular Climbing Spots</h2>
          <ExploreList />
        </section>
      </div>
    </div>
  );
}
