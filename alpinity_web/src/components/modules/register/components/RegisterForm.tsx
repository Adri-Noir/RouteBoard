"use client";

import { Button, buttonVariants } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { postApiAuthenticationRegisterMutation } from "@/lib/api/@tanstack/react-query.gen";
import useAuth from "@/lib/hooks/useAuth";
import { cn } from "@/lib/utils";
import { useForm } from "@tanstack/react-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import Cookies from "js-cookie";
import { CalendarIcon, Camera, Loader2, Upload } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useCallback, useState } from "react";

const RegisterForm = () => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const { isAuthenticated } = useAuth();
  const [datePickerOpen, setDatePickerOpen] = useState(false);
  const [selectedPhoto, setSelectedPhoto] = useState<File | null>(null);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);

  const {
    mutate: registerUser,
    isPending: isRegisterLoading,
    isError: isRegisterError,
    error: registerError,
  } = useMutation({
    ...postApiAuthenticationRegisterMutation(),
    onSuccess: (data) => {
      if (data.token) {
        Cookies.set("token", data.token);
        queryClient.invalidateQueries();
        queryClient.clear();
      }
      router.push("/");
    },
  });

  const form = useForm({
    defaultValues: {
      email: "",
      username: "",
      password: "",
      confirmPassword: "",
      firstName: "",
      lastName: "",
      dateOfBirth: undefined as Date | undefined,
    },
    onSubmit: (data) => {
      registerUser({
        body: {
          Email: data.value.email,
          Username: data.value.username,
          Password: data.value.password,
          FirstName: data.value.firstName || undefined,
          LastName: data.value.lastName || undefined,
          DateOfBirth: data.value.dateOfBirth ? format(data.value.dateOfBirth, "yyyy-MM-dd") : undefined,
          ProfilePhoto: selectedPhoto || undefined,
        },
      });
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

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  };

  if (isAuthenticated) {
    setTimeout(() => {
      router.push("/");
    }, 1000);
    return <p className="text-muted-foreground text-center text-sm">Redirecting to home...</p>;
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Basic Info */}
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
              required
            />
            {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
          </div>
        )}
      </form.Field>

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
              required
            />
            {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
          </div>
        )}
      </form.Field>

      <div className="grid grid-cols-2 gap-4">
        <form.Field name="password">
          {(field) => (
            <div className="space-y-2">
              <Label htmlFor={field.name}>Password</Label>
              <Input
                id={field.name}
                name={field.name}
                type="password"
                placeholder="Enter password"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                required
              />
              {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
            </div>
          )}
        </form.Field>

        <form.Field name="confirmPassword">
          {(field) => (
            <div className="space-y-2">
              <Label htmlFor={field.name}>Confirm Password</Label>
              <Input
                id={field.name}
                name={field.name}
                type="password"
                placeholder="Confirm password"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                required
              />
              {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
            </div>
          )}
        </form.Field>
      </div>

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
              <PopoverContent className="w-auto p-0" align="start">
                <Calendar
                  mode="single"
                  captionLayout="dropdown"
                  startMonth={new Date(1900, 0, 1)}
                  endMonth={new Date(new Date().getFullYear(), 11, 31)}
                  selected={field.state.value}
                  onSelect={(selectedDate: Date | undefined) => {
                    if (selectedDate) {
                      field.handleChange(selectedDate);
                      setDatePickerOpen(false);
                    }
                  }}
                />
              </PopoverContent>
            </Popover>
            {field.state.meta.errors && <p className="text-sm text-red-500">{field.state.meta.errors[0]}</p>}
          </div>
        )}
      </form.Field>

      {/* Photo Upload */}
      <div className="flex flex-col items-center space-y-3">
        <div className="border-input dark:border-input relative h-24 w-24 overflow-hidden rounded-full border">
          {photoPreview ? (
            <ImageWithLoading
              src={photoPreview}
              alt="Photo preview"
              fill
              className="object-cover"
              containerClassName="h-full w-full rounded-full"
            />
          ) : (
            <div className="bg-muted text-muted-foreground flex h-full w-full items-center justify-center">
              <Camera className="h-8 w-8" />
            </div>
          )}
        </div>
        <Label htmlFor="photo-upload" className={cn(buttonVariants({ variant: "outline" }), "cursor-pointer")}>
          <Upload className="h-4 w-4" />
          <span className="text-foreground">{selectedPhoto ? "Change Photo" : "Add Profile Photo"}</span>
          <Input id="photo-upload" type="file" accept="image/*" className="hidden" onChange={handlePhotoUpload} />
        </Label>
      </div>

      {/* Submit Button */}
      <form.Subscribe selector={(state) => [state.canSubmit, state.isSubmitting]}>
        {([canSubmit, isSubmitting]) => (
          <Button type="submit" className="w-full" disabled={!canSubmit || isRegisterLoading}>
            {isSubmitting || isRegisterLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Creating Account...
              </>
            ) : (
              "Create Account"
            )}
          </Button>
        )}
      </form.Subscribe>

      {isRegisterError && (
        <p className="text-destructive text-center text-sm">
          {registerError?.errors?.[0]?.message || registerError?.detail || "An error occurred while creating account"}
        </p>
      )}

      {/* Link to login page */}
      <div className="mt-4 text-center text-sm">
        Already have an account?{" "}
        <Link href="/login" className="underline underline-offset-4">
          Log in
        </Link>
      </div>
    </form>
  );
};

export default RegisterForm;
