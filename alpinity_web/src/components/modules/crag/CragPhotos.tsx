"use client";

import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from "@/components/ui/carousel";
import { Dialog, DialogContent } from "@/components/ui/dialog";
import { PhotoDto } from "@/lib/api/types.gen";
import Image from "next/image";
import { useState } from "react";

interface CragPhotosProps {
  photos: PhotoDto[];
}

const CragPhotos = ({ photos }: CragPhotosProps) => {
  const [openDialog, setOpenDialog] = useState(false);
  const [currentPhoto, setCurrentPhoto] = useState<PhotoDto | null>(null);

  const handlePhotoClick = (photo: PhotoDto) => {
    setCurrentPhoto(photo);
    setOpenDialog(true);
  };

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
                <Image src={photo.url || ""} alt={photo.description || "Crag photo"} fill className="object-cover" />
              </div>
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious />
        <CarouselNext />
      </Carousel>

      <Dialog open={openDialog} onOpenChange={setOpenDialog}>
        <DialogContent className="max-w-4xl">
          {currentPhoto && (
            <div className="relative aspect-video overflow-hidden rounded-md">
              <Image
                src={currentPhoto.url || ""}
                alt={currentPhoto.description || "Crag photo"}
                fill
                className="object-contain"
              />
              {currentPhoto.description && (
                <div className="absolute right-0 bottom-0 left-0 bg-black/50 p-2 text-sm text-white">
                  {currentPhoto.description}
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
};

export default CragPhotos;
