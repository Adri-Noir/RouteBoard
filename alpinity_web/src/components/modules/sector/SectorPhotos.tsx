"use client";

import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
  type CarouselApi,
} from "@/components/ui/carousel";
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { PhotoDto } from "@/lib/api/types.gen";
import { useEffect, useState } from "react";

interface SectorPhotosProps {
  photos: PhotoDto[];
}

const SectorPhotos = ({ photos }: SectorPhotosProps) => {
  const [openDialog, setOpenDialog] = useState(false);
  const [currentPhotoIndex, setCurrentPhotoIndex] = useState(0);
  const [dialogCarouselApi, setDialogCarouselApi] = useState<CarouselApi>();

  const handlePhotoClick = (photo: PhotoDto) => {
    const index = photos.findIndex((p) => p.id === photo.id);
    setCurrentPhotoIndex(index);
    setOpenDialog(true);
  };

  useEffect(() => {
    if (dialogCarouselApi && openDialog) {
      dialogCarouselApi.scrollTo(currentPhotoIndex, true);
    }
  }, [dialogCarouselApi, openDialog, currentPhotoIndex]);

  return (
    <>
      <Carousel className="w-full max-w-full">
        <CarouselContent>
          {photos.map((photo) => (
            <CarouselItem key={photo.id} className="basis-full md:basis-1/2 lg:basis-1/3">
              <div
                className="relative aspect-video cursor-pointer overflow-hidden rounded-lg"
                onClick={() => handlePhotoClick(photo)}
              >
                {photo.url && (
                  <ImageWithLoading
                    src={photo.url}
                    alt={`Sector photo ${photo.id}`}
                    fill
                    className="object-cover"
                    sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
                    containerClassName="aspect-video"
                  />
                )}
              </div>
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious />
        <CarouselNext />
      </Carousel>

      <Dialog open={openDialog} onOpenChange={setOpenDialog}>
        <DialogContent className="sm:max-w-7xl" aria-describedby={"sector-photos"}>
          <DialogTitle>Sector Photos</DialogTitle>
          <div className="flex flex-col gap-4 px-12">
            <Carousel setApi={setDialogCarouselApi} className="w-full">
              <CarouselContent>
                {photos.map((photo) => (
                  <CarouselItem key={photo.id}>
                    <div className="relative aspect-video overflow-hidden rounded-md">
                      <ImageWithLoading
                        src={photo.url || ""}
                        alt={`Sector photo ${photo.id}`}
                        fill
                        className="object-contain"
                        containerClassName="aspect-video"
                      />
                    </div>
                  </CarouselItem>
                ))}
              </CarouselContent>
              <CarouselPrevious />
              <CarouselNext />
            </Carousel>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
};

export default SectorPhotos;
