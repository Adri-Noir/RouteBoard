"use client";

import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { TypeBadge } from "@/components/ui/library/Badge/TypeBadge";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { postApiUserLogAscentMutation } from "@/lib/api/@tanstack/react-query.gen";
import type {
  AscentType,
  ClimbingGrade,
  ClimbType,
  HoldType,
  LogAscentCommand,
  RockType,
  SectorRouteDto,
} from "@/lib/api/types.gen";
import { cn } from "@/lib/utils";
import { formatClimbingGrade, formatClimbType, formatHoldType, formatRockType } from "@/lib/utils/formatters";
import { useForm } from "@tanstack/react-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import { CalendarIcon, Loader2, Star } from "lucide-react";
import { useState } from "react";

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

const ASCENT_TYPES: AscentType[] = ["Onsight", "Flash", "Redpoint", "Aid"];

const CLIMB_TYPES: ClimbType[] = ["Endurance", "Powerful", "Technical"];

const ROCK_TYPES: RockType[] = ["Vertical", "Overhang", "Roof", "Slab", "Arete", "Dihedral"];

const HOLD_TYPES: HoldType[] = ["Crack", "Crimps", "Slopers", "Pinches", "Jugs", "Pockets"];

interface LogAscentFormProps {
  route: SectorRouteDto;
  onSuccess?: () => void;
  onCancel?: () => void;
}

const LogAscentForm = ({ route, onSuccess, onCancel }: LogAscentFormProps) => {
  const queryClient = useQueryClient();
  const [selectedClimbTypes, setSelectedClimbTypes] = useState<Set<ClimbType>>(new Set());
  const [selectedRockTypes, setSelectedRockTypes] = useState<Set<RockType>>(new Set());
  const [selectedHoldTypes, setSelectedHoldTypes] = useState<Set<HoldType>>(new Set());
  const [rating, setRating] = useState<number>(0);
  const [datePickerOpen, setDatePickerOpen] = useState(false);

  const {
    mutate: logAscent,
    isPending: isLoading,
    isError,
    error,
  } = useMutation({
    ...postApiUserLogAscentMutation(),
    onSuccess: () => {
      queryClient.invalidateQueries();
      if (onSuccess) {
        onSuccess();
      }
    },
  });

  const form = useForm({
    defaultValues: {
      ascentDate: new Date(),
      notes: "",
      ascentType: "Redpoint" as AscentType,
      numberOfAttempts: 1,
      proposedGrade: (route.grade || "PROJECT") as ClimbingGrade | "none",
    },
    onSubmit: (data) => {
      const command: LogAscentCommand = {
        routeId: route.id,
        ascentDate: format(data.value.ascentDate, "yyyy-MM-dd"),
        notes: data.value.notes || undefined,
        climbTypes: selectedClimbTypes.size > 0 ? Array.from(selectedClimbTypes) : undefined,
        rockTypes: selectedRockTypes.size > 0 ? Array.from(selectedRockTypes) : undefined,
        holdTypes: selectedHoldTypes.size > 0 ? Array.from(selectedHoldTypes) : undefined,
        ascentType: data.value.ascentType,
        numberOfAttempts: data.value.numberOfAttempts || undefined,
        proposedGrade: data.value.proposedGrade === "none" ? undefined : data.value.proposedGrade,
        rating: rating > 0 ? rating : undefined,
      };

      logAscent({ body: command });
    },
  });

  const handleClimbTypeChange = (climbType: ClimbType, checked: boolean) => {
    if (checked) {
      setSelectedClimbTypes((prev) => new Set(prev).add(climbType));
    } else {
      setSelectedClimbTypes((prev) => {
        const newSet = new Set(prev);
        newSet.delete(climbType);
        return newSet;
      });
    }
  };

  const handleRockTypeChange = (rockType: RockType, checked: boolean) => {
    if (checked) {
      setSelectedRockTypes((prev) => new Set(prev).add(rockType));
    } else {
      setSelectedRockTypes((prev) => {
        const newSet = new Set(prev);
        newSet.delete(rockType);
        return newSet;
      });
    }
  };

  const handleHoldTypeChange = (holdType: HoldType, checked: boolean) => {
    if (checked) {
      setSelectedHoldTypes((prev) => new Set(prev).add(holdType));
    } else {
      setSelectedHoldTypes((prev) => {
        const newSet = new Set(prev);
        newSet.delete(holdType);
        return newSet;
      });
    }
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  };

  return (
    <div className="mx-auto w-full max-w-2xl">
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Date and Ascent Type */}
        <div className="grid grid-cols-2 gap-4">
          <form.Field name="ascentDate">
            {(field) => (
              <div className="space-y-2">
                <Label htmlFor={field.name}>Date *</Label>
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
                        captionLayout="dropdown"
                        startMonth={new Date(1900, 0, 1)}
                        endMonth={new Date(new Date().getFullYear(), 11, 31)}
                        selected={field.state.value}
                        onSelect={(selectedDate) => {
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
                {field.state.meta.errors && <p className="text-destructive text-sm">{field.state.meta.errors[0]}</p>}
              </div>
            )}
          </form.Field>

          <form.Field name="proposedGrade">
            {(field) => (
              <div className="w-full space-y-2">
                <Label htmlFor={field.name}>Proposed Grade</Label>
                <Select
                  value={field.state.value}
                  onValueChange={(value) => field.handleChange(value as ClimbingGrade | "none")}
                >
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select grade (optional)" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">No grade</SelectItem>
                    {CLIMBING_GRADES.map((grade) => (
                      <SelectItem key={grade} value={grade}>
                        {formatClimbingGrade(grade)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {field.state.meta.errors && <p className="text-destructive text-sm">{field.state.meta.errors[0]}</p>}
              </div>
            )}
          </form.Field>
        </div>

        {/* Number of Attempts and Proposed Grade */}
        <div className="grid grid-cols-2 gap-4">
          <form.Field name="numberOfAttempts">
            {(field) => (
              <div className="w-full space-y-2">
                <Label htmlFor={field.name}>Number of Attempts</Label>
                <Input
                  id={field.name}
                  name={field.name}
                  type="number"
                  min="1"
                  placeholder="1"
                  value={field.state.value || ""}
                  onBlur={field.handleBlur}
                  onChange={(e) => {
                    const value = e.target.value;
                    field.handleChange(value ? parseInt(value) : 1);
                  }}
                  className="w-full"
                />
                {field.state.meta.errors && <p className="text-destructive text-sm">{field.state.meta.errors[0]}</p>}
              </div>
            )}
          </form.Field>

          <form.Field name="ascentType">
            {(field) => (
              <div className="w-full space-y-2">
                <Label htmlFor={field.name}>Ascent Type *</Label>
                <Select value={field.state.value} onValueChange={(value) => field.handleChange(value as AscentType)}>
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select ascent type" />
                  </SelectTrigger>
                  <SelectContent>
                    {ASCENT_TYPES.map((type) => (
                      <SelectItem key={type} value={type}>
                        {type}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {field.state.meta.errors && <p className="text-destructive text-sm">{field.state.meta.errors[0]}</p>}
              </div>
            )}
          </form.Field>
        </div>

        {/* Rating */}
        <div className="space-y-2">
          <Label>Rating</Label>
          <div className="flex items-center space-x-1">
            {[1, 2, 3, 4, 5].map((star) => (
              <button
                key={star}
                type="button"
                onClick={() => setRating(star === rating ? 0 : star)}
                className="p-1 transition-transform hover:scale-110"
              >
                <Star
                  className={`h-6 w-6 ${star <= rating ? "fill-yellow-400 text-yellow-400" : "text-muted-foreground hover:text-yellow-400"}`}
                />
              </button>
            ))}
            {rating > 0 && (
              <span className="text-muted-foreground ml-2 text-sm">
                {rating} star{rating !== 1 ? "s" : ""}
              </span>
            )}
          </div>
        </div>

        {/* Climb Types */}
        <div className="space-y-3">
          <Label>Climb Types</Label>
          <div className="flex flex-wrap gap-2">
            {CLIMB_TYPES.map((type) => (
              <Button
                variant="link"
                size="sm"
                type="button"
                key={type}
                onClick={() => handleClimbTypeChange(type, !selectedClimbTypes.has(type))}
                className="hover:underline-0 p-0 hover:no-underline"
              >
                <TypeBadge
                  label={formatClimbType(type)}
                  variant={selectedClimbTypes.has(type) ? "primary" : "secondary"}
                  className="px-2 py-1"
                />
              </Button>
            ))}
          </div>
        </div>

        {/* Rock Types */}
        <div className="space-y-3">
          <Label>Rock Types</Label>
          <div className="flex flex-wrap gap-2">
            {ROCK_TYPES.map((type) => (
              <Button
                variant="link"
                size="sm"
                type="button"
                key={type}
                onClick={() => handleRockTypeChange(type, !selectedRockTypes.has(type))}
                className="hover:underline-0 p-0 hover:no-underline"
              >
                <TypeBadge
                  label={formatRockType(type)}
                  variant={selectedRockTypes.has(type) ? "primary" : "secondary"}
                  className="px-2 py-1"
                />
              </Button>
            ))}
          </div>
        </div>

        {/* Hold Types */}
        <div className="space-y-3">
          <Label>Hold Types</Label>
          <div className="flex flex-wrap gap-2">
            {HOLD_TYPES.map((type) => (
              <Button
                variant="link"
                size="sm"
                type="button"
                key={type}
                onClick={() => handleHoldTypeChange(type, !selectedHoldTypes.has(type))}
                className="hover:underline-0 p-0 hover:no-underline"
              >
                <TypeBadge
                  label={formatHoldType(type)}
                  variant={selectedHoldTypes.has(type) ? "primary" : "secondary"}
                  className="px-2 py-1"
                />
              </Button>
            ))}
          </div>
        </div>

        {/* Notes */}
        <form.Field name="notes">
          {(field) => (
            <div className="space-y-2">
              <Label htmlFor={field.name}>Notes</Label>
              <Textarea
                id={field.name}
                name={field.name}
                placeholder="Add any notes about your ascent..."
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                rows={6}
              />
              {field.state.meta.errors && <p className="text-destructive text-sm">{field.state.meta.errors[0]}</p>}
            </div>
          )}
        </form.Field>

        {/* Error Display */}
        {isError && (
          <div className="border-destructive/20 bg-destructive/10 rounded-md border p-4">
            <p className="text-destructive text-sm">
              {error instanceof Error ? error.message : "Failed to log ascent. Please try again."}
            </p>
          </div>
        )}

        {/* Action Buttons */}
        <div className="flex justify-end space-x-3 pt-4">
          {onCancel && (
            <Button type="button" variant="outline" onClick={onCancel}>
              Cancel
            </Button>
          )}
          <Button type="submit" disabled={isLoading}>
            {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            Log Ascent
          </Button>
        </div>
      </form>
    </div>
  );
};

export default LogAscentForm;
