import { ClimbingGrade } from "@/lib/api/types.gen";
import { cn } from "@/lib/utils";
import { formatClimbingGrade } from "@/lib/utils/formatters";
import { getGradeColorClass } from "@/lib/utils/gradeUtils";

interface GradeBadgeProps {
  grade: ClimbingGrade;
  className?: string;
}

/**
 * A badge component for displaying climbing grades
 * @param grade The climbing grade to display
 * @param className Additional classes to apply
 */
export const GradeBadge = ({ grade, className }: GradeBadgeProps) => {
  const colorClass = getGradeColorClass(grade);

  return (
    <span className={cn("rounded-md px-2 py-1 text-xs font-semibold", colorClass, className)}>
      {formatClimbingGrade(grade)}
    </span>
  );
};
