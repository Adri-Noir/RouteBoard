import { ARFeature } from "./components/ARFeature";
import { CallToAction } from "./components/CallToAction";
import { Features } from "./components/Features";
import { Hero } from "./components/Hero";

export const Home = () => {
  return (
    <div className="min-h-screen">
      <Hero />
      <Features />
      <ARFeature />
      <CallToAction />
    </div>
  );
};
