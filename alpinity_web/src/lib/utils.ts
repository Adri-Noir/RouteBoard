import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatClimbingGrade(grade: string | undefined): string {
  if (!grade) return "";

  if (grade === "PROJECT") return "Project";

  return grade.replace("F_", "").replace("_plus", "+");
}
