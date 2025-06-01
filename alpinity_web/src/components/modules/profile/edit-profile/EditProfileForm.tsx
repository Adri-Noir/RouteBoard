"use client";

import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { putApiUserEditMutation, putApiUserPhotoMutation } from "@/lib/api/@tanstack/react-query.gen";
import type { UserProfileDto } from "@/lib/api/types.gen";
import useAuth from "@/lib/hooks/useAuth";
import { cn } from "@/lib/utils";
import { useForm } from "@tanstack/react-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import { CalendarIcon, Camera, Loader2, Upload, X } from "lucide-react";
import { useCallback, useState } from "react";

interface EditProfileFormProps {
  onSuccess?: (user?: UserProfileDto) => void;
}

const EditProfileForm = ({ onSuccess }: EditProfileFormProps) => {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const [datePickerOpen, setDatePickerOpen] = useState(false);
  const [selectedPhoto, setSelectedPhoto] = useState<File | null>(null);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);
  const [showPhotoOnly, setShowPhotoOnly] = useState(false);

  const {
    mutate: updateUser,
    isPending: isUpdateLoading,
    isError: isUpdateError,
    error: updateError,
  } = useMutation({
    ...putApiUserEditMutation(),
    onSuccess: (data) => {
      queryClient.invalidateQueries();
      if (onSuccess) {
        onSuccess(data);
      }
    },
  });

  const {
    mutate: updatePhoto,
    isPending: isPhotoLoading,
    isError: isPhotoError,
    error: photoError,
  } = useMutation({
    ...putApiUserPhotoMutation(),
    onSuccess: () => {
      queryClient.invalidateQueries();
      setSelectedPhoto(null);
      setPhotoPreview(null);
      if (onSuccess) {
        onSuccess();
      }
    },
  });

  const form = useForm({
    defaultValues: {
      username: user?.username || "",
      email: user?.email || "",
      firstName: user?.firstName || "",
      lastName: user?.lastName || "",
      dateOfBirth: user?.dateOfBirth ? new Date(user.dateOfBirth) : undefined,
      password: "",
    },
    onSubmit: (data) => {
      const updateData: {
        username?: string;
        email?: string;
        firstName?: string;
        lastName?: string;
        dateOfBirth?: string;
        password?: string;
      } = {};

      // Only include fields that have values and are different from current user data
      if (data.value.username && data.value.username !== user?.username) {
        updateData.username = data.value.username;
      }
      if (data.value.email && data.value.email !== user?.email) {
        updateData.email = data.value.email;
      }
      if (data.value.firstName && data.value.firstName !== user?.firstName) {
        updateData.firstName = data.value.firstName;
      }
      if (data.value.lastName && data.value.lastName !== user?.lastName) {
        updateData.lastName = data.value.lastName;
      }
      if (data.value.dateOfBirth) {
        updateData.dateOfBirth = format(data.value.dateOfBirth, "yyyy-MM-dd");
      }
      if (data.value.password) {
        updateData.password = data.value.password;
      }

      // Only submit if there are changes
      if (Object.keys(updateData).length > 0) {
        updateUser({
          body: updateData,
        });
      }
    },
  });

  const handlePhotoUpload = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedPhoto(file);
      const reader = new FileReader();
      reader.onload = (event) => {
        setPhotoPreview(event.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  }, []);

  const handlePhotoSubmit = useCallback(() => {
    if (selectedPhoto && user?.id) {
      updatePhoto({
        body: {
          UserId: user.id,
          Photo: selectedPhoto,
        },
      });
    }
  }, [selectedPhoto, user?.id, updatePhoto]);

  const handlePhotoCancel = useCallback(() => {
    setSelectedPhoto(null);
    setPhotoPreview(null);
  }, []);

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  };

  return (
    <div className="w-full space-y-8">
      {!showPhotoOnly ? (
        <>
          {/* Profile Information Form */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Profile Information</h3>

            <form onSubmit={handleSubmit} className="space-y-6">
              <form.Field name="username">
                {(field) => (
                  <div className="space-y-2">
                    <Label htmlFor={field.name}>Username</Label>
                    <Input
                      id={field.name}
                      name={field.name}
                      type="text"
                      placeholder="Enter username"
                      value={field.state.value}
                      onBlur={field.handleBlur}
                      onChange={(e) => field.handleChange(e.target.value)}
                    />
                    {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
                  </div>
                )}
              </form.Field>

              <form.Field name="email">
                {(field) => (
                  <div className="space-y-2">
                    <Label htmlFor={field.name}>Email</Label>
                    <Input
                      id={field.name}
                      name={field.name}
                      type="email"
                      placeholder="Enter email"
                      value={field.state.value}
                      onBlur={field.handleBlur}
                      onChange={(e) => field.handleChange(e.target.value)}
                    />
                    {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
                  </div>
                )}
              </form.Field>

              <div className="grid grid-cols-2 gap-4">
                <form.Field name="firstName">
                  {(field) => (
                    <div className="space-y-2">
                      <Label htmlFor={field.name}>First Name</Label>
                      <Input
                        id={field.name}
                        name={field.name}
                        type="text"
                        placeholder="Enter first name"
                        value={field.state.value}
                        onBlur={field.handleBlur}
                        onChange={(e) => field.handleChange(e.target.value)}
                      />
                      {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
                    </div>
                  )}
                </form.Field>

                <form.Field name="lastName">
                  {(field) => (
                    <div className="space-y-2">
                      <Label htmlFor={field.name}>Last Name</Label>
                      <Input
                        id={field.name}
                        name={field.name}
                        type="text"
                        placeholder="Enter last name"
                        value={field.state.value}
                        onBlur={field.handleBlur}
                        onChange={(e) => field.handleChange(e.target.value)}
                      />
                      {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
                    </div>
                  )}
                </form.Field>
              </div>

              <form.Field name="dateOfBirth">
                {(field) => (
                  <div className="space-y-2">
                    <Label htmlFor={field.name}>Date of Birth</Label>
                    <Popover open={datePickerOpen} onOpenChange={setDatePickerOpen}>
                      <PopoverTrigger asChild>
                        <Button
                          variant="outline"
                          className={cn(
                            "w-full justify-start text-left font-normal",
                            !field.state.value && "text-muted-foreground",
                          )}
                        >
                          <CalendarIcon className="mr-2 h-4 w-4" />
                          {field.state.value ? format(field.state.value, "PPP") : <span>Pick a date</span>}
                        </Button>
                      </PopoverTrigger>
                      <PopoverContent className="pointer-events-auto w-auto p-0" align="start">
                        <div className="pointer-events-auto">
                          <Calendar
                            mode="single"
                            selected={field.state.value}
                            onSelect={(selectedDate: Date | undefined) => {
                              if (selectedDate) {
                                field.handleChange(selectedDate);
                                setDatePickerOpen(false);
                              }
                            }}
                            className="pointer-events-auto"
                          />
                        </div>
                      </PopoverContent>
                    </Popover>
                    {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
                  </div>
                )}
              </form.Field>

              <form.Field name="password">
                {(field) => (
                  <div className="space-y-2">
                    <Label htmlFor={field.name}>New Password</Label>
                    <Input
                      id={field.name}
                      name={field.name}
                      type="password"
                      placeholder="Enter new password (leave empty to keep current)"
                      value={field.state.value}
                      onBlur={field.handleBlur}
                      onChange={(e) => field.handleChange(e.target.value)}
                    />
                    {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
                  </div>
                )}
              </form.Field>

              {/* Photo Only Button */}
              <Button
                type="button"
                variant="outline"
                onClick={() => setShowPhotoOnly(true)}
                className="flex w-full items-center justify-center space-x-2"
              >
                <Camera className="h-4 w-4" />
                <span>Edit Photo</span>
              </Button>

              <form.Subscribe selector={(state) => [state.canSubmit, state.isSubmitting]}>
                {([canSubmit, isSubmitting]) => (
                  <Button type="submit" className="w-full" disabled={!canSubmit || isUpdateLoading}>
                    {isSubmitting || isUpdateLoading ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Updating Profile...
                      </>
                    ) : (
                      "Update Profile"
                    )}
                  </Button>
                )}
              </form.Subscribe>

              {isUpdateError && (
                <p className="text-center text-sm text-red-500">
                  {updateError?.detail || "An error occurred while updating your profile"}
                </p>
              )}
            </form>
          </div>
        </>
      ) : (
        /* Photo Only View */
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Camera className="h-5 w-5" />
              <h3 className="text-lg font-semibold">Edit Profile Photo</h3>
            </div>
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => setShowPhotoOnly(false)}
              className="flex items-center space-x-2"
            >
              <X className="h-4 w-4" />
              <span>Back to Full Form</span>
            </Button>
          </div>

          <div className="flex flex-col items-center space-y-6">
            {/* Current Photo - Larger in photo-only view */}
            <div className="flex flex-col items-center space-y-3">
              <div className="relative h-32 w-32 overflow-hidden rounded-full border-2 border-gray-200">
                {user?.profilePhoto?.url ? (
                  <ImageWithLoading
                    src={user.profilePhoto.url}
                    alt="Current profile photo"
                    fill
                    className="object-cover"
                    containerClassName="h-full w-full rounded-full"
                  />
                ) : (
                  <div className="flex h-full w-full items-center justify-center bg-gray-100 text-gray-400">
                    <Camera className="h-12 w-12" />
                  </div>
                )}
              </div>
              <span className="text-foreground text-sm">Current Photo</span>
            </div>

            {/* Photo Preview - Larger in photo-only view */}
            {photoPreview && (
              <div className="flex flex-col items-center space-y-3">
                <div className="relative h-32 w-32 overflow-hidden rounded-full border-2 border-blue-200">
                  <ImageWithLoading
                    src={photoPreview}
                    alt="Photo preview"
                    fill
                    className="object-cover"
                    containerClassName="h-full w-full rounded-full"
                  />
                </div>
                <span className="text-foreground text-sm">New Photo Preview</span>
              </div>
            )}

            {/* Upload Controls - Centered in photo-only view */}
            <div className="flex flex-col items-center space-y-4">
              {!selectedPhoto ? (
                <Label
                  htmlFor="photo-upload-only"
                  className="flex cursor-pointer items-center space-x-2 rounded-md border border-gray-300 bg-white px-6 py-3 text-sm font-medium
                    text-gray-700 hover:bg-gray-50"
                >
                  <Upload className="h-5 w-5" />
                  <span className="text-foreground">Choose New Photo</span>
                  <Input
                    id="photo-upload-only"
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={handlePhotoUpload}
                  />
                </Label>
              ) : (
                <div className="flex space-x-3">
                  <Button type="button" onClick={handlePhotoSubmit} disabled={isPhotoLoading} className="px-6">
                    {isPhotoLoading ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Uploading...
                      </>
                    ) : (
                      "Upload New Photo"
                    )}
                  </Button>
                  <Button type="button" variant="outline" onClick={handlePhotoCancel} disabled={isPhotoLoading}>
                    Cancel
                  </Button>
                </div>
              )}

              {isPhotoError && <p className="text-sm text-red-500">{photoError?.detail || "Failed to upload photo"}</p>}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default EditProfileForm;
