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
        <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl md:text-6xl">
          Discover Your Next Adventure
        </h1>
        <p className="mx-auto mt-6 max-w-lg text-xl text-white">
          Find the perfect routes for hiking, climbing, and outdoor activities
        </p>

        {/* Search Bar */}
        <HeroInput />
      </div>
    </div>
  );
};
