"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { TypeBadge } from "@/components/ui/library/Badge/TypeBadge";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { postApiRouteMutation, putApiRouteByIdMutation } from "@/lib/api/@tanstack/react-query.gen";
import type { ClimbingGrade, RouteDetailedDto, RouteType } from "@/lib/api/types.gen";
import { useForm } from "@tanstack/react-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Loader2, Mountain, RotateCcw, Trash } from "lucide-react";
import { useCallback, useState } from "react";

const CLIMBING_GRADES: ClimbingGrade[] = [
  "PROJECT",
  "F_1",
  "F_2",
  "F_3",
  "F_4a",
  "F_4b",
  "F_4c",
  "F_5a",
  "F_5b",
  "F_5c",
  "F_6a",
  "F_6a_plus",
  "F_6b",
  "F_6b_plus",
  "F_6c",
  "F_6c_plus",
  "F_7a",
  "F_7a_plus",
  "F_7b",
  "F_7b_plus",
  "F_7c",
  "F_7c_plus",
  "F_8a",
  "F_8a_plus",
  "F_8b",
  "F_8b_plus",
  "F_8c",
  "F_8c_plus",
  "F_9a",
  "F_9a_plus",
  "F_9b",
  "F_9b_plus",
  "F_9c",
  "F_9c_plus",
  "F_10a",
];

const ROUTE_TYPES: RouteType[] = [
  "Boulder",
  "Sport",
  "Trad",
  "MultiPitch",
  "Ice",
  "BigWall",
  "Mixed",
  "Aid",
  "ViaFerrata",
];

const formatGrade = (grade: ClimbingGrade): string => {
  if (grade === "PROJECT") return "Project";
  return grade.replace("F_", "").replace("_plus", "+");
};

const formatRouteType = (type: RouteType): string => {
  switch (type) {
    case "MultiPitch":
      return "Multi-Pitch";
    case "BigWall":
      return "Big Wall";
    case "ViaFerrata":
      return "Via Ferrata";
    default:
      return type;
  }
};

interface CreateRouteFormProps {
  route?: RouteDetailedDto;
  sectorId?: string;
  onSuccess?: (route: RouteDetailedDto) => void;
}

const CreateRouteForm = ({ route, sectorId, onSuccess }: CreateRouteFormProps) => {
  const queryClient = useQueryClient();
  const [selectedRouteTypes, setSelectedRouteTypes] = useState<Set<RouteType>>(new Set(route?.routeType || []));
  const [photosToRemove, setPhotosToRemove] = useState<string[]>([]);

  const isEditing = !!route;

  const {
    mutate: createRoute,
    isPending: isCreateLoading,
    isError: isCreateError,
    error: createError,
  } = useMutation({
    ...postApiRouteMutation(),
    onSuccess: (data) => {
      queryClient.invalidateQueries();
      if (onSuccess) {
        onSuccess(data);
      }
    },
  });

  const {
    mutate: updateRoute,
    isPending: isUpdateLoading,
    isError: isUpdateError,
    error: updateError,
  } = useMutation({
    ...putApiRouteByIdMutation(),
    onSuccess: (data) => {
      queryClient.invalidateQueries();
      if (onSuccess) {
        onSuccess(data);
      }
    },
  });

  const form = useForm({
    defaultValues: {
      name: route?.name || "",
      description: route?.description || "",
      grade: route?.grade || ("F_5a" as ClimbingGrade),
      length: route?.length || 0,
    },
    onSubmit: (data) => {
      if (isEditing && route?.id) {
        const routeTypesOld = new Set(route.routeType || []);
        const routeTypesChanged =
          routeTypesOld.size !== selectedRouteTypes.size ||
          [...routeTypesOld].some((type) => !selectedRouteTypes.has(type)) ||
          [...selectedRouteTypes].some((type) => !routeTypesOld.has(type));

        updateRoute({
          path: { id: route.id },
          body: {
            name: data.value.name !== route.name ? data.value.name || undefined : undefined,
            description: data.value.description !== route.description ? data.value.description || undefined : undefined,
            grade: data.value.grade !== route.grade ? data.value.grade : undefined,
            routeType: routeTypesChanged
              ? selectedRouteTypes.size > 0
                ? Array.from(selectedRouteTypes)
                : undefined
              : undefined,
            length: data.value.length !== route.length ? data.value.length || undefined : undefined,
            photosToRemove: photosToRemove.length > 0 ? photosToRemove : undefined,
          },
        });
      } else {
        const targetSectorId = sectorId || route?.sectorId;
        if (!targetSectorId) {
          console.error("Sector ID is required for creating a route");
          return;
        }

        createRoute({
          body: {
            name: data.value.name,
            description: data.value.description || undefined,
            grade: data.value.grade,
            routeType: selectedRouteTypes.size > 0 ? Array.from(selectedRouteTypes) : undefined,
            length: data.value.length || undefined,
            sectorId: targetSectorId,
          },
        });
      }
    },
  });

  const handleRouteTypeChange = (routeType: RouteType, checked: boolean) => {
    if (checked) {
      setSelectedRouteTypes((prev) => {
        const newSet = new Set(prev);
        newSet.add(routeType);
        return newSet;
      });
    } else {
      setSelectedRouteTypes((prev) => {
        const newSet = new Set(prev);
        newSet.delete(routeType);
        return newSet;
      });
    }
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  };

  const isLoading = isCreateLoading || isUpdateLoading;
  const isError = isCreateError || isUpdateError;
  const error = createError || updateError;

  const toggleExistingPhotoRemoval = useCallback((photoId: string) => {
    setPhotosToRemove((prev) => {
      if (prev.includes(photoId)) {
        return prev.filter((id) => id !== photoId);
      }
      return [...prev, photoId];
    });
  }, []);

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
                placeholder="Enter route name"
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
                placeholder="Enter route description"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                rows={4}
              />
              {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
            </div>
          )}
        </form.Field>

        <div className="grid grid-cols-2 gap-4">
          <form.Field name="grade">
            {(field) => (
              <div className="w-full space-y-2">
                <Label htmlFor={field.name}>Grade *</Label>
                <Select value={field.state.value} onValueChange={(value) => field.handleChange(value as ClimbingGrade)}>
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select grade" />
                  </SelectTrigger>
                  <SelectContent>
                    {CLIMBING_GRADES.map((grade) => (
                      <SelectItem key={grade} value={grade}>
                        {formatGrade(grade)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
              </div>
            )}
          </form.Field>

          <form.Field name="length">
            {(field) => (
              <div className="w-full space-y-2">
                <Label htmlFor={field.name}>Length (meters)</Label>
                <Input
                  id={field.name}
                  name={field.name}
                  type="number"
                  min="0"
                  step="0.1"
                  placeholder="0"
                  value={field.state.value}
                  onBlur={field.handleBlur}
                  onChange={(e) => field.handleChange(parseFloat(e.target.value) || 0)}
                />
                {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
              </div>
            )}
          </form.Field>
        </div>

        {/* Route Types Section */}
        <div className="space-y-4">
          <div className="flex items-center gap-2">
            <Mountain className="h-4 w-4" />
            <Label>Route Types</Label>
          </div>
          <div className="flex flex-wrap gap-2">
            {ROUTE_TYPES.map((routeType) => (
              <Button
                variant="link"
                size="sm"
                type="button"
                key={routeType}
                onClick={() => handleRouteTypeChange(routeType, !selectedRouteTypes.has(routeType))}
                className="hover:underline-0 p-0 hover:no-underline"
              >
                <TypeBadge
                  label={formatRouteType(routeType)}
                  variant={selectedRouteTypes.has(routeType) ? "primary" : "secondary"}
                  className="px-2 py-1"
                />
              </Button>
            ))}
          </div>
        </div>

        {/* Photos Section (Editing Only) */}
        {isEditing && route?.routePhotos && route.routePhotos.length > 0 && (
          <div className="space-y-4">
            <Label>Photos</Label>

            <div className="space-y-2">
              <p className="text-muted-foreground text-sm">Existing Photos</p>
              <div className="grid grid-cols-2 gap-4 md:grid-cols-3">
                {route.routePhotos.map((photo) => {
                  const marked = photosToRemove.includes(photo.id);
                  return (
                    <div key={photo.id} className="group relative h-40 w-full">
                      {photo.combinedPhoto?.url && (
                        <ImageWithLoading
                          src={photo.combinedPhoto.url}
                          alt="Route photo"
                          fill
                          className={`rounded-md object-contain ${marked ? "opacity-50" : ""}`}
                          containerClassName="h-full w-full"
                        />
                      )}

                      {/* Overlay indicating deletion */}
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
          </div>
        )}

        <form.Subscribe selector={(state) => [state.canSubmit, state.isSubmitting]}>
          {([canSubmit, isSubmitting]) => (
            <Button type="submit" className="w-full" disabled={!canSubmit || isLoading}>
              {isSubmitting || isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  {isEditing ? "Updating..." : "Creating..."}
                </>
              ) : isEditing ? (
                "Update Route"
              ) : (
                "Create Route"
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

export default CreateRouteForm;
