"use client";

import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from "@/components/ui/carousel";
import { PhotoDto } from "@/lib/api/types.gen";
import Image from "next/image";

interface SectorPhotosProps {
  photos: PhotoDto[];
}

const SectorPhotos = ({ photos }: SectorPhotosProps) => {
  return (
    <Carousel className="w-full max-w-full">
      <CarouselContent>
        {photos.map((photo) => (
          <CarouselItem key={photo.id} className="basis-full md:basis-1/2 lg:basis-1/3">
            <div className="relative aspect-video overflow-hidden rounded-lg">
              {photo.url && (
                <Image
                  src={photo.url}
                  alt={`Sector photo ${photo.id}`}
                  fill
                  className="object-cover"
                  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
                />
              )}
            </div>
          </CarouselItem>
        ))}
      </CarouselContent>
      <CarouselPrevious />
      <CarouselNext />
    </Carousel>
  );
};

export default SectorPhotos;
