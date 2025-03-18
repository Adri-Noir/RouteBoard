import { ClimbingGrade } from "@/lib/api/types.gen";

/**
 * Formats a climbing grade from API format (F_6a_plus) to display format (6a+)
 */
export function formatClimbingGrade(grade: ClimbingGrade): string {
  if (grade === "PROJECT") return "Project";

  // Remove the F_ prefix
  let formatted = grade.replace("F_", "");

  // Replace _plus with +
  formatted = formatted.replace("_plus", "+");

  return formatted;
}
