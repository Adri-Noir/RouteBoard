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
                <Image src={photo.url || ""} alt={`Crag photo ${photo.id}`} fill className="object-cover" />
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
                alt={`Crag photo ${currentPhoto.id}`}
                fill
                className="object-contain"
              />
            </div>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
};

export default CragPhotos;
