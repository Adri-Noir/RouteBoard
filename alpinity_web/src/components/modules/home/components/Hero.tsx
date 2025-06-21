import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import HeroInput from "./HeroInput";

export const Hero = () => {
  return (
    <div className="relative h-[600px] w-full">
      {/* Hero Image */}
      <div className="absolute inset-0 z-0">
        <ImageWithLoading
          src="/images/hero_image.jpg"
          alt="Mountain landscape"
          fill
          priority
          quality={50}
          sizes="100vw"
          className="h-full w-full object-cover"
          containerClassName="h-full w-full"
        />
        <div className="absolute inset-0 bg-black/70" /> {/* Overlay for better text visibility */}
      </div>

      {/* Content */}
      <div className="relative z-10 flex h-full flex-col items-center justify-center px-4 text-center sm:px-6 lg:px-8">
        <h1 className="text-4xl font-extrabold tracking-tight text-white sm:text-5xl md:text-6xl">
          Climb Smarter with Alpinity
        </h1>
        <p className="mx-auto mt-6 max-w-2xl text-xl text-white/90">
          Real-time route recognition, detailed topos and personal climbing analytics – all in one modern guidebook.
        </p>

        {/* Search Bar */}
        <HeroInput />
      </div>
    </div>
  );
};
