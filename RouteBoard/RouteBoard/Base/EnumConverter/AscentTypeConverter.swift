// Created with <3 on 08.03.2025.

import Foundation
import GeneratedClient

class AscentTypeConverter {
  static func convertToString(_ ascentType: Components.Schemas.AscentType?) -> String? {
    guard let ascentType = ascentType else {
      return nil
    }

    switch ascentType {
    case .Onsight:
      return "Onsight"
    case .Flash:
      return "Flash"
    case .Redpoint:
      return "Redpoint"
    case .Aid:
      return "Aid"
    }
  }
}
