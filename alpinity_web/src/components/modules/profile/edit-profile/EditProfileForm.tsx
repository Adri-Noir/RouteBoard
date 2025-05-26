"use client";

import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { putApiUserEditMutation } from "@/lib/api/@tanstack/react-query.gen";
import type { UserProfileDto } from "@/lib/api/types.gen";
import useAuth from "@/lib/hooks/useAuth";
import { cn } from "@/lib/utils";
import { useForm } from "@tanstack/react-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import { CalendarIcon, Loader2 } from "lucide-react";
import { useState } from "react";

interface EditProfileFormProps {
  onSuccess?: (user: UserProfileDto) => void;
}

const EditProfileForm = ({ onSuccess }: EditProfileFormProps) => {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const [datePickerOpen, setDatePickerOpen] = useState(false);

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

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  };

  return (
    <div className="w-full">
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
  );
};

export default EditProfileForm;
