// Created with <3 on 27.02.2025.

import GeneratedClient

// raw values of userclimbingtype doesn't need to match the components.schemas.climbType raw values

public enum UserClimbingType: String, Codable, Hashable, Sendable, CaseIterable {
  case Endurance = "Endurance"
  case Powerful = "Powerful"
  case Technical = "Technical"

  case Vertical = "Vertical"
  case Overhang = "Overhang"
  case Roof = "Roof"
  case Slab = "Slab"
  case Arete = "Arete"
  case Dihedral = "Dihedral"

  case Crack = "Cracks"
  case Crimps = "Crimps"
  case Slopers = "Slopers"
  case Pinches = "Pinches"
  case Jugs = "Jugs"
  case Pockets = "Pockets"
  case Pinch = "Pinching"
}

public class ClimbTypesConverter {
  public static let allClimbingTypes: [UserClimbingType] = [
    .Endurance,
    .Powerful,
    .Technical,

    .Vertical,
    .Overhang,
    .Roof,
    .Slab,
    .Arete,
    .Dihedral,

    .Crack,
    .Crimps,
    .Slopers,
    .Pinches,
    .Jugs,
    .Pockets,
  ]

  public static func convertUserClimbingTypeToComponentsClimbType(
    userClimbingType: UserClimbingType
  )
    -> Components.Schemas.ClimbType?
  {
    switch userClimbingType {
    case .Endurance:
      return .Endurance
    case .Powerful:
      return .Powerful
    case .Technical:
      return .Technical
    default:
      return nil
    }
  }

  public static func convertComponentsClimbTypeToUserClimbingType(
    componentsClimbType: Components.Schemas.ClimbType
  )
    -> UserClimbingType
  {
    switch componentsClimbType {
    case .Endurance:
      return .Endurance
    case .Powerful:
      return .Powerful
    case .Technical:
      return .Technical
    }
  }

  public static func convertUserClimbingTypeToComponentsRockType(userClimbingType: UserClimbingType)
    -> Components.Schemas.RockType?
  {
    switch userClimbingType {
    case .Vertical:
      return .Vertical
    case .Overhang:
      return .Overhang
    case .Roof:
      return .Roof
    case .Slab:
      return .Slab
    case .Arete:
      return .Arete
    case .Dihedral:
      return .Dihedral
    default:
      return nil
    }
  }

  public static func convertComponentsRockTypeToUserClimbingType(
    componentsRockType: Components.Schemas.RockType
  )
    -> UserClimbingType
  {
    switch componentsRockType {
    case .Vertical:
      return .Vertical
    case .Overhang:
      return .Overhang
    case .Roof:
      return .Roof
    case .Slab:
      return .Slab
    case .Arete:
      return .Arete
    case .Dihedral:
      return .Dihedral
    }
  }

  public static func convertUserClimbingTypeToComponentsHoldType(userClimbingType: UserClimbingType)
    -> Components.Schemas.HoldType?
  {
    switch userClimbingType {
    case .Crack:
      return .Crack
    case .Crimps:
      return .Crimps
    case .Slopers:
      return .Slopers
    case .Pinches:
      return .Pinches
    case .Jugs:
      return .Jugs
    case .Pockets:
      return .Pockets
    default:
      return nil
    }
  }

  public static func convertComponentsHoldTypeToUserClimbingType(
    componentsHoldType: Components.Schemas.HoldType
  )
    -> UserClimbingType
  {
    switch componentsHoldType {
    case .Crack:
      return .Crack
    case .Crimps:
      return .Crimps
    case .Slopers:
      return .Slopers
    case .Pinches:
      return .Pinches
    case .Jugs:
      return .Jugs
    case .Pockets:
      return .Pockets
    }
  }

  public static func convertUserClimbingTypesToComponentsClimbTypes(
    userClimbingTypes: [UserClimbingType]
  )
    -> [Components.Schemas.ClimbType]
  {
    return userClimbingTypes.compactMap {
      convertUserClimbingTypeToComponentsClimbType(userClimbingType: $0)
    }
  }

  public static func convertComponentsClimbTypesToUserClimbingTypes(
    componentsClimbTypes: [Components.Schemas.ClimbType]
  )
    -> [UserClimbingType]
  {
    return componentsClimbTypes.compactMap {
      convertComponentsClimbTypeToUserClimbingType(componentsClimbType: $0)
    }
  }

  public static func convertUserClimbingTypesToComponentsRockTypes(
    userClimbingTypes: [UserClimbingType]
  )
    -> [Components.Schemas.RockType]
  {
    return userClimbingTypes.compactMap {
      convertUserClimbingTypeToComponentsRockType(userClimbingType: $0)
    }
  }

  public static func convertComponentsRockTypesToUserClimbingTypes(
    componentsRockTypes: [Components.Schemas.RockType]
  )
    -> [UserClimbingType]
  {
    return componentsRockTypes.compactMap {
      convertComponentsRockTypeToUserClimbingType(componentsRockType: $0)
    }
  }

  public static func convertUserClimbingTypesToComponentsHoldTypes(
    userClimbingTypes: [UserClimbingType]
  )
    -> [Components.Schemas.HoldType]
  {
    return userClimbingTypes.compactMap {
      convertUserClimbingTypeToComponentsHoldType(userClimbingType: $0)
    }
  }

  public static func convertComponentsHoldTypesToUserClimbingTypes(
    componentsHoldTypes: [Components.Schemas.HoldType]
  )
    -> [UserClimbingType]
  {
    return componentsHoldTypes.compactMap {
      convertComponentsHoldTypeToUserClimbingType(componentsHoldType: $0)
    }
  }
}
