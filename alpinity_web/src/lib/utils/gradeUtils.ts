import { ClimbingGrade } from "@/lib/api/types.gen";

/**
 * Returns the appropriate color code for a climbing grade
 */
export const getGradeColor = (grade: ClimbingGrade | string): string => {
  // If grade is a string, normalize it to match ClimbingGrade format
  const normalizedGrade =
    typeof grade === "string" ? (grade.replace("+", "_plus").replace(/^(\d+)/, "F_$1") as ClimbingGrade) : grade;

  if (normalizedGrade === "PROJECT") return "hsl(215, 14%, 34%)";

  // F_4 grades - blue
  if (["F_4a", "F_4b", "F_4c"].includes(normalizedGrade)) {
    return "hsl(217, 91%, 60%)";
  }

  // F_5 grades - green
  if (["F_5a", "F_5b", "F_5c"].includes(normalizedGrade)) {
    return "hsl(142, 76%, 36%)";
  }

  // F_6 grades - yellow
  if (["F_6a", "F_6a_plus", "F_6b", "F_6b_plus", "F_6c", "F_6c_plus"].includes(normalizedGrade)) {
    return "hsl(48, 96%, 53%)";
  }

  // F_7 grades - orange
  if (["F_7a", "F_7a_plus", "F_7b", "F_7b_plus", "F_7c", "F_7c_plus"].includes(normalizedGrade)) {
    return "hsl(28, 98%, 54%)";
  }

  // F_8 grades - red
  if (["F_8a", "F_8a_plus", "F_8b", "F_8b_plus", "F_8c", "F_8c_plus"].includes(normalizedGrade)) {
    return "hsl(0, 84%, 60%)";
  }

  // F_9 grades - purple
  if (["F_9a", "F_9a_plus", "F_9b", "F_9b_plus", "F_9c", "F_9c_plus"].includes(normalizedGrade)) {
    return "hsl(280, 67%, 63%)";
  }

  // Default - gray (for any unhandled grades)
  return "hsl(215, 14%, 34%)";
};

/**
 * Returns the appropriate background color class based on the climbing grade
 */
export const getGradeColorClass = (grade: ClimbingGrade): string => {
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
 * Extracts grade info for sorting
 * @param grade String representation of the climbing grade
 */
const extractGradeInfo = (grade: string): { family: number; letter: string; hasPlus: boolean } => {
  // Handle "PROJECT" as a special case
  if (grade === "PROJECT") {
    return { family: -1, letter: "", hasPlus: false };
  }

  // Parse the grade format (e.g., "7a+", "6c", "8b+", etc.)
  const matches = grade.match(/^(\d+)([a-c])(\+)?$/);

  if (!matches) {
    // Default for unparseable grades
    return { family: 0, letter: "a", hasPlus: false };
  }

  const [, familyStr, letter, plus] = matches;

  return {
    family: parseInt(familyStr, 10),
    letter,
    hasPlus: !!plus,
  };
};

/**
 * Sort function for climbing grades
 * Used to sort grade distribution items in ascending order
 */
export const sortGradeDistributionItems = <T extends { grade: string }>(items: T[]): T[] => {
  return [...items].sort((a, b) => {
    const gradeA = extractGradeInfo(a.grade);
    const gradeB = extractGradeInfo(b.grade);

    // Sort by grade family first (4, 5, 6, 7, etc.)
    if (gradeA.family !== gradeB.family) {
      return gradeA.family - gradeB.family;
    }

    // Then by letter (a, b, c)
    if (gradeA.letter !== gradeB.letter) {
      return gradeA.letter.localeCompare(gradeB.letter);
    }

    // Finally by plus modifier (no plus, then plus)
    return gradeA.hasPlus ? 1 : gradeB.hasPlus ? -1 : 0;
  });
};
