"use client";

import { Carousel, CarouselContent, CarouselItem } from "@/components/ui/carousel";
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
                  alt={photo.description || "Sector photo"}
                  fill
                  className="object-cover"
                  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
                />
              )}
            </div>
            {photo.description && <p className="text-muted-foreground mt-2 text-sm">{photo.description}</p>}
          </CarouselItem>
        ))}
      </CarouselContent>
    </Carousel>
  );
};

export default SectorPhotos;
