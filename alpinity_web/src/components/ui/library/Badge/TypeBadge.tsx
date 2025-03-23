import { cn } from "@/lib/utils";

type TypeBadgeVariant = "primary" | "secondary";

interface TypeBadgeProps {
  label: string;
  variant?: TypeBadgeVariant;
  className?: string;
}

/**
 * A badge component for displaying route types and categories
 * @param label The text to display in the badge
 * @param variant "primary" for route types, "secondary" for categories
 * @param className Additional classes to apply
 */
export const TypeBadge = ({ label, variant = "secondary", className }: TypeBadgeProps) => {
  return (
    <span
      className={cn(
        "inline-block rounded-full px-2 py-0.5 text-xs md:mb-1",
        variant === "primary" ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground",
        className,
      )}
    >
      {label}
    </span>
  );
};
