import { ClimbingGrade, ClimbType, HoldType, RockType, RouteType } from "@/lib/api/types.gen";

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

/**
 * Formats a climbing type to be more readable
 */
export function formatClimbType(type: ClimbType): string {
  switch (type) {
    case "Endurance":
      return "Endurance";
    case "Powerful":
      return "Powerful";
    case "Technical":
      return "Technical";
  }
}

/**
 * Formats a rock type to be more readable
 */
export function formatRockType(type: RockType): string {
  switch (type) {
    case "Vertical":
      return "Vertical";
    case "Overhang":
      return "Overhang";
    case "Roof":
      return "Roof";
    case "Slab":
      return "Slab";
    case "Arete":
      return "Arete";
    case "Dihedral":
      return "Dihedral";
  }
}

/**
 * Formats a hold type to be more readable
 */
export function formatHoldType(type: HoldType): string {
  switch (type) {
    case "Crack":
      return "Crack";
    case "Crimps":
      return "Crimps";
    case "Slopers":
      return "Slopers";
    case "Pinches":
      return "Pinches";
    case "Jugs":
      return "Jugs";
    case "Pockets":
      return "Pockets";
  }
}

/**
 * Formats a route type to be more readable
 */
export function formatRouteType(type: RouteType): string {
  switch (type) {
    case "Boulder":
      return "Boulder";
    case "Sport":
      return "Sport";
    case "Trad":
      return "Trad";
    case "MultiPitch":
      return "Multi-Pitch";
    case "Ice":
      return "Ice";
    case "BigWall":
      return "Big Wall";
    case "Mixed":
      return "Mixed";
    case "Aid":
      return "Aid";
    case "ViaFerrata":
      return "Via Ferrata";
  }
}

/**
 * Formats any climbing category type
 */
export function formatClimbingCategoryType(type: ClimbType | RockType | HoldType): string {
  // Check if the type is a ClimbType
  if (type === "Powerful" || type === "Technical") {
    return formatClimbType(type as ClimbType);
  }

  // Check if the type is a RockType
  if (
    type === "Vertical" ||
    type === "Overhang" ||
    type === "Roof" ||
    type === "Slab" ||
    type === "Arete" ||
    type === "Dihedral"
  ) {
    return formatRockType(type as RockType);
  }

  // Otherwise, assume it's a HoldType
  return formatHoldType(type as HoldType);
}
