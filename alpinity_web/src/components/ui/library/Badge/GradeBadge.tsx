import { ClimbingGrade } from "@/lib/api/types.gen";
import { cn } from "@/lib/utils";
import { formatClimbingGrade } from "@/lib/utils/formatters";

interface GradeBadgeProps {
  grade: ClimbingGrade;
  className?: string;
}

/**
 * Returns the appropriate background color class based on the climbing grade
 */
const getGradeColorClass = (grade: ClimbingGrade): string => {
  if (grade === "PROJECT") return "bg-gray-500/20 text-gray-700";

  // F_4 grades - blue
  if (["F_4a", "F_4b", "F_4c"].includes(grade)) {
    return "bg-blue-500/20 text-blue-700";
  }

  // F_5 grades - green
  if (["F_5a", "F_5b", "F_5c"].includes(grade)) {
    return "bg-green-500/20 text-green-700";
  }

  // F_6 grades - yellow
  if (["F_6a", "F_6a_plus", "F_6b", "F_6b_plus", "F_6c", "F_6c_plus"].includes(grade)) {
    return "bg-yellow-500/20 text-yellow-700";
  }

  // F_7 grades - orange
  if (["F_7a", "F_7a_plus", "F_7b", "F_7b_plus", "F_7c", "F_7c_plus"].includes(grade)) {
    return "bg-orange-500/20 text-orange-700";
  }

  // F_8 grades - red
  if (["F_8a", "F_8a_plus", "F_8b", "F_8b_plus", "F_8c", "F_8c_plus"].includes(grade)) {
    return "bg-red-500/20 text-red-700";
  }

  // F_9 grades - purple
  if (["F_9a", "F_9a_plus", "F_9b", "F_9b_plus", "F_9c", "F_9c_plus"].includes(grade)) {
    return "bg-purple-500/20 text-purple-700";
  }

  // Default - gray (for any unhandled grades)
  return "bg-gray-500/20 text-gray-700";
};

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
