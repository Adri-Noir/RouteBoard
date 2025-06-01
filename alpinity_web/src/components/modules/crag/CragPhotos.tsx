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

interface CragPhotosProps {
  photos: PhotoDto[];
}

const CragPhotos = ({ photos }: CragPhotosProps) => {
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
      <Carousel className="w-full">
        <CarouselContent>
          {photos.map((photo) => (
            <CarouselItem key={photo.id} className="md:basis-1/2 lg:basis-1/3">
              <div
                className="relative aspect-video cursor-pointer overflow-hidden rounded-md"
                onClick={() => handlePhotoClick(photo)}
              >
                <ImageWithLoading
                  src={photo.url || ""}
                  alt={`Crag photo ${photo.id}`}
                  fill
                  className="object-cover"
                  containerClassName="aspect-video"
                  priority={false}
                  sizes="(max-width: 768px) 100vw, 33vw"
                />
              </div>
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious />
        <CarouselNext />
      </Carousel>

      <Dialog open={openDialog} onOpenChange={setOpenDialog}>
        <DialogContent className="sm:max-w-7xl" aria-describedby={"crag-photos"}>
          <DialogTitle>Crag Photos</DialogTitle>
          <div className="flex flex-col gap-4 px-12">
            <Carousel setApi={setDialogCarouselApi} className="w-full">
              <CarouselContent>
                {photos.map((photo) => (
                  <CarouselItem key={photo.id}>
                    <div className="relative aspect-video overflow-hidden rounded-md">
                      <ImageWithLoading
                        src={photo.url || ""}
                        alt={`Crag photo ${photo.id}`}
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

export default CragPhotos;
