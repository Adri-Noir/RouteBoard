// Created with <3 on 08.03.2025.

import Foundation
import GeneratedClient

class RouteTypeConverter {
  static func convertToString(_ routeType: Components.Schemas.RouteType?) -> String? {
    guard let routeType = routeType else {
      return nil
    }

    switch routeType {
    case .Boulder:
      return "Boulder"
    case .Sport:
      return "Sport"
    case .Trad:
      return "Trad"
    case .MultiPitch:
      return "Multi-pitch"
    case .Ice:
      return "Ice"
    case .BigWall:
      return "Big Wall"
    case .Mixed:
      return "Mixed"
    case .Aid:
      return "Aid"
    case .ViaFerrata:
      return "Via Ferrata"
    }
  }
}
