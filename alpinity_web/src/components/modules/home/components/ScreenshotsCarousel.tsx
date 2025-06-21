import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from "@/components/ui/carousel";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";

const screenshots = [
  {
    src: "/images/features/crag-details-top.png",
    alt: "Crag details interface",
  },
  {
    src: "/images/features/crag-weather-1.png",
    alt: "Weather component",
  },
  {
    src: "/images/features/geo_karta_ceuse.png",
    alt: "Interactive map example",
  },
  {
    src: "/images/features/search_searching.png",
    alt: "Search functionality",
  },
  {
    src: "/images/features/user-profile-other.png",
    alt: "User profile screen",
  },
  {
    src: "/images/features/manual_detect.PNG",
    alt: "Manual detection",
  },
];

export const ScreenshotsCarousel = () => {
  return (
    <section className="py-24">
      <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
        <div className="mb-12 text-center">
          <h2 className="text-primary text-base font-semibold tracking-wide uppercase">Take a peek</h2>
          <p className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl">App screenshots</p>
          <p className="text-muted-foreground mx-auto mt-4 max-w-xl text-xl">
            A quick look at the Alpinity interface across different features.
          </p>
        </div>

        <Carousel className="relative w-full overflow-hidden">
          <CarouselPrevious className="top-1/2 !left-2 z-20 -translate-y-1/2" />
          <CarouselContent>
            {screenshots.map((shot, index) => (
              <CarouselItem key={index} className="flex items-center justify-center">
                <div className="relative h-[520px] w-full sm:h-[640px] md:h-[680px] lg:h-[700px]">
                  <ImageWithLoading
                    src={shot.src}
                    alt={shot.alt}
                    fill
                    sizes="(max-width: 768px) 80vw, 40vw"
                    className="rounded-xl object-center shadow-lg"
                    containerClassName="h-full w-full"
                  />
                </div>
              </CarouselItem>
            ))}
          </CarouselContent>
          <CarouselNext className="top-1/2 !right-2 z-20 -translate-y-1/2" />
        </Carousel>
      </div>
    </section>
  );
};
