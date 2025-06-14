"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { Textarea } from "@/components/ui/textarea";
import { postApiCragMutation, putApiCragByIdMutation } from "@/lib/api/@tanstack/react-query.gen";
import type { CragDetailedDto } from "@/lib/api/types.gen";
import { useForm } from "@tanstack/react-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Loader2, Upload, X } from "lucide-react";
import { useCallback, useState } from "react";

interface CreateCragFormProps {
  crag?: CragDetailedDto;
  onSuccess?: (crag: CragDetailedDto) => void;
}

export function CreateCragForm({ crag, onSuccess }: CreateCragFormProps) {
  const queryClient = useQueryClient();
  const [photos, setPhotos] = useState<File[]>([]);
  const [photosToRemove, setPhotosToRemove] = useState<string[]>([]);

  const isEditing = !!crag;

  const {
    mutate: createCrag,
    isPending: isCreateLoading,
    isError: isCreateError,
    error: createError,
  } = useMutation({
    ...postApiCragMutation(),
    onSuccess: (data) => {
      queryClient.invalidateQueries();
      if (onSuccess) {
        onSuccess(data);
      }
    },
  });

  const {
    mutate: updateCrag,
    isPending: isUpdateLoading,
    isError: isUpdateError,
    error: updateError,
  } = useMutation({
    ...putApiCragByIdMutation(),
    onSuccess: (data) => {
      queryClient.invalidateQueries();
      if (onSuccess) {
        onSuccess(data);
      }
    },
  });

  const form = useForm({
    defaultValues: {
      name: crag?.name || "",
      description: crag?.description || "",
      locationName: crag?.locationName || "",
    },
    onSubmit: (data) => {
      if (isEditing && crag?.id) {
        updateCrag({
          path: { id: crag.id },
          body: {
            Id: crag.id,
            Name: data.value.name !== crag.name ? data.value.name : undefined,
            Description: data.value.description !== crag.description ? data.value.description || undefined : undefined,
            LocationName:
              data.value.locationName !== crag.locationName ? data.value.locationName || undefined : undefined,
            Photos: photos.length > 0 ? photos : undefined,
            PhotosToRemove: photosToRemove.length > 0 ? photosToRemove : undefined,
          },
        });
      } else {
        createCrag({
          body: {
            Name: data.value.name,
            Description: data.value.description || undefined,
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

  const removeExistingPhoto = useCallback((photoId: string) => {
    setPhotosToRemove((prev) => [...prev, photoId]);
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
                placeholder="Enter crag name"
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
                placeholder="Enter crag description"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                rows={4}
              />
              {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
            </div>
          )}
        </form.Field>

        <form.Field name="locationName">
          {(field) => (
            <div className="space-y-2">
              <Label htmlFor={field.name}>Location Name</Label>
              <Input
                id={field.name}
                name={field.name}
                type="text"
                placeholder="Enter location name"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
              />
              {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
            </div>
          )}
        </form.Field>

        {/* Photo Upload Section */}
        <div className="space-y-4">
          <Label>Photos</Label>

          {/* Existing Photos (for editing) */}
          {isEditing && crag?.photos && crag.photos.length > 0 && (
            <div className="space-y-2">
              <p className="text-muted-foreground text-sm">Existing Photos</p>
              <div className="grid grid-cols-2 gap-4 md:grid-cols-3">
                {crag.photos
                  .filter((photo) => !photosToRemove.includes(photo.id))
                  .map((photo) => (
                    <div key={photo.id} className="group relative h-40 w-full">
                      <ImageWithLoading
                        src={photo.url || ""}
                        alt="Crag photo"
                        fill
                        className="rounded-md object-contain"
                        containerClassName="h-full w-full"
                      />
                      <Button
                        type="button"
                        variant="destructive"
                        size="sm"
                        className="absolute top-1 right-1 opacity-0 transition-opacity group-hover:opacity-100"
                        onClick={() => removeExistingPhoto(photo.id)}
                      >
                        <X className="h-3 w-3" />
                      </Button>
                    </div>
                  ))}
              </div>
            </div>
          )}

          {/* New Photos */}
          {photos.length > 0 && (
            <div className="space-y-2">
              <p className="text-muted-foreground text-sm">New Photos</p>
              <div className="grid grid-cols-2 gap-4 md:grid-cols-3">
                {photos.map((photo, index) => (
                  <div key={index} className="group relative h-40 w-full">
                    <ImageWithLoading
                      src={URL.createObjectURL(photo)}
                      alt="New crag photo"
                      fill
                      className="rounded-md object-contain"
                      containerClassName="h-full w-full"
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
                "Update Crag"
              ) : (
                "Create Crag"
              )}
            </Button>
          )}
        </form.Subscribe>

        {isError && <p className="text-center text-sm text-red-500">{error?.detail || "An error occurred"}</p>}
      </form>
    </div>
  );
}

export default CreateCragForm;
