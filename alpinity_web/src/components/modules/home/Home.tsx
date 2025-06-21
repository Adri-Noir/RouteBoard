import { ARFeature } from "./components/ARFeature";
import { CallToAction } from "./components/CallToAction";
import { Hero } from "./components/Hero";
import { Overview } from "./components/Overview";
import { ScreenshotsCarousel } from "./components/ScreenshotsCarousel";

export const Home = () => {
  return (
    <div className="min-h-screen">
      <Hero />
      <Overview />
      <ScreenshotsCarousel />
      <ARFeature />
      <CallToAction />
    </div>
  );
};
