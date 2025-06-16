"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { postApiSectorMutation, putApiSectorByIdMutation } from "@/lib/api/@tanstack/react-query.gen";
import type { SectorDetailedDto } from "@/lib/api/types.gen";
import { useForm } from "@tanstack/react-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Loader2, RotateCcw, Trash, Upload, X } from "lucide-react";
import Image from "next/image";
import { useCallback, useState } from "react";
import LocationPicker from "./LocationPicker";

interface CreateSectorFormProps {
  sector?: SectorDetailedDto;
  cragId?: string;
  cragLocation?: { latitude: number; longitude: number };
  onSuccess?: (sector: SectorDetailedDto) => void;
}

const CreateSectorForm = ({ sector, cragId, cragLocation, onSuccess }: CreateSectorFormProps) => {
  const queryClient = useQueryClient();
  const [photos, setPhotos] = useState<File[]>([]);
  const [photosToRemove, setPhotosToRemove] = useState<string[]>([]);

  const isEditing = !!sector;

  const {
    mutate: createSector,
    isPending: isCreateLoading,
    isError: isCreateError,
    error: createError,
  } = useMutation({
    ...postApiSectorMutation(),
    onSuccess: (data) => {
      queryClient.invalidateQueries();
      if (onSuccess) {
        onSuccess(data);
      }
    },
  });

  const {
    mutate: updateSector,
    isPending: isUpdateLoading,
    isError: isUpdateError,
    error: updateError,
  } = useMutation({
    ...putApiSectorByIdMutation(),
    onSuccess: (data) => {
      queryClient.invalidateQueries();
      if (onSuccess) {
        onSuccess(data);
      }
    },
  });

  const form = useForm({
    defaultValues: {
      name: sector?.name || "",
      description: sector?.description || "",
      latitude: sector?.location?.latitude || 0,
      longitude: sector?.location?.longitude || 0,
    },
    onSubmit: (data) => {
      // Ensure latitude and longitude are properly formatted as decimal numbers
      const latitude = Number(data.value.latitude);
      const longitude = Number(data.value.longitude);

      // Validate coordinates
      if (isNaN(latitude) || isNaN(longitude)) {
        console.error("Invalid coordinates:", { latitude: data.value.latitude, longitude: data.value.longitude });
        return;
      }

      if (latitude === 0 && longitude === 0) {
        console.error("Please select a location on the map");
        return;
      }

      if (isEditing && sector?.id) {
        updateSector({
          path: { id: sector.id },
          body: {
            Id: sector.id,
            Name: data.value.name !== sector.name ? data.value.name : undefined,
            Description:
              data.value.description !== sector.description ? data.value.description || undefined : undefined,
            "Location.Latitude": latitude,
            "Location.Longitude": longitude,
            Photos: photos.length > 0 ? photos : undefined,
            PhotosToRemove: photosToRemove.length > 0 ? photosToRemove : undefined,
          },
        });
      } else {
        const targetCragId = cragId || sector?.cragId;
        if (!targetCragId) {
          console.error("Crag ID is required for creating a sector");
          return;
        }

        createSector({
          body: {
            Name: data.value.name,
            Description: data.value.description || undefined,
            "Location.Latitude": latitude,
            "Location.Longitude": longitude,
            CragId: targetCragId,
            Photos: photos.length > 0 ? photos : undefined,
          },
        });
      }
    },
  });

  const handlePhotoUpload = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    setPhotos((prev) => [...prev, ...files]);
  }, []);

  const removePhoto = useCallback((index: number) => {
    setPhotos((prev) => prev.filter((_, i) => i !== index));
  }, []);

  const toggleExistingPhotoRemoval = useCallback((photoId: string) => {
    setPhotosToRemove((prev) => {
      if (prev.includes(photoId)) {
        return prev.filter((id) => id !== photoId);
      }
      return [...prev, photoId];
    });
  }, []);

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  };

  const isLoading = isCreateLoading || isUpdateLoading;
  const isError = isCreateError || isUpdateError;
  const error = createError || updateError;

  return (
    <div className="w-full">
      <form onSubmit={handleSubmit} className="space-y-6">
        <form.Field name="name">
          {(field) => (
            <div className="space-y-2">
              <Label htmlFor={field.name}>Name *</Label>
              <Input
                id={field.name}
                name={field.name}
                type="text"
                placeholder="Enter sector name"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                required
              />
              {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
            </div>
          )}
        </form.Field>

        <form.Field name="description">
          {(field) => (
            <div className="space-y-2">
              <Label htmlFor={field.name}>Description</Label>
              <Textarea
                id={field.name}
                name={field.name}
                placeholder="Enter sector description"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                rows={4}
              />
              {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
            </div>
          )}
        </form.Field>

        {/* Location Section */}
        <form.Subscribe selector={(state) => [state.values.latitude, state.values.longitude]}>
          {([latitude, longitude]) => (
            <LocationPicker
              latitude={latitude}
              longitude={longitude}
              onLocationChange={(lat: number, lng: number) => {
                form.setFieldValue("latitude", lat);
                form.setFieldValue("longitude", lng);
              }}
              cragLocation={cragLocation}
            />
          )}
        </form.Subscribe>

        {/* Photo Upload Section */}
        <div className="space-y-4">
          <Label>Photos</Label>

          {/* Existing Photos (for editing) */}
          {isEditing && sector?.photos && sector.photos.length > 0 && (
            <div className="space-y-2">
              <p className="text-muted-foreground text-sm">Existing Photos</p>
              <div className="grid grid-cols-2 gap-4 md:grid-cols-3">
                {sector.photos.map((photo) => {
                  const marked = photosToRemove.includes(photo.id);
                  return (
                    <div key={photo.id} className="relative">
                      <Image
                        src={photo.url || ""}
                        alt="Sector photo"
                        width={200}
                        height={96}
                        className={`h-24 w-full rounded-md object-cover ${marked ? "opacity-50" : ""}`}
                      />
                      {marked && (
                        <div
                          className="bg-destructive/60 pointer-events-none absolute inset-0 z-10 flex items-center justify-center rounded-md text-xs
                            font-semibold text-white"
                        >
                          Marked for deletion
                        </div>
                      )}
                      <Button
                        type="button"
                        variant={marked ? "secondary" : "destructive"}
                        size="sm"
                        className="absolute top-1 right-1 z-20"
                        onClick={() => toggleExistingPhotoRemoval(photo.id)}
                      >
                        {marked ? <RotateCcw className="h-3 w-3" /> : <Trash className="h-3 w-3" />}
                      </Button>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* New Photos */}
          {photos.length > 0 && (
            <div className="space-y-2">
              <p className="text-muted-foreground text-sm">New Photos</p>
              <div className="grid grid-cols-2 gap-4 md:grid-cols-3">
                {photos.map((photo, index) => (
                  <div key={index} className="group relative">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={URL.createObjectURL(photo)}
                      alt="New sector photo"
                      className="h-24 w-full rounded-md object-cover"
                    />
                    <Button
                      type="button"
                      variant="destructive"
                      size="sm"
                      className="absolute top-1 right-1 opacity-0 transition-opacity group-hover:opacity-100"
                      onClick={() => removePhoto(index)}
                    >
                      <X className="h-3 w-3" />
                    </Button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Upload Button */}
          <div className="flex w-full items-center justify-center">
            <Label
              htmlFor="photo-upload"
              className="border-input bg-muted/50 text-muted-foreground hover:bg-muted/40 dark:bg-input/30 dark:hover:bg-input/50 flex h-32
                w-full cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed"
            >
              <div className="flex flex-col items-center justify-center pt-5 pb-6">
                <Upload className="text-muted-foreground mb-4 h-8 w-8" />
                <p className="text-muted-foreground mb-2 text-sm">
                  <span className="font-semibold">Click to upload</span> photos
                </p>
                <p className="text-muted-foreground text-xs">PNG, JPG or JPEG</p>
              </div>
              <Input
                id="photo-upload"
                type="file"
                multiple
                accept="image/*"
                className="hidden"
                onChange={handlePhotoUpload}
              />
            </Label>
          </div>
        </div>

        <form.Subscribe selector={(state) => [state.canSubmit, state.isSubmitting]}>
          {([canSubmit, isSubmitting]) => (
            <Button type="submit" className="w-full" disabled={!canSubmit || isLoading}>
              {isSubmitting || isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  {isEditing ? "Updating..." : "Creating..."}
                </>
              ) : isEditing ? (
                "Update Sector"
              ) : (
                "Create Sector"
              )}
            </Button>
          )}
        </form.Subscribe>

        {isError && (
          <p className="text-center text-sm text-red-500">{error?.errors?.[0]?.message || "An error occurred"}</p>
        )}
      </form>
    </div>
  );
};

export default CreateSectorForm;
