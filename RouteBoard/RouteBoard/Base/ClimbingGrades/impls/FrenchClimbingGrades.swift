//
//  FrenchClimbingGrades.swift
//  RouteBoard
//
//  Created with <3 on 04.07.2024..
//

import Foundation
import GeneratedClient
import SwiftUI

class FrenchClimbingGrades: ClimbingGrades {

  var climbingGrades: [String] = [
    "?", "4a", "4b", "4c", "5a", "5b", "5c", "6a", "6a+", "6b", "6b+", "6c", "6c+", "7a", "7a+",
    "7b",
    "7b+", "7c", "7c+", "8a", "8a+", "8b", "8b+", "8c", "8c+", "9a", "9a+", "9b", "9b+", "9c",
    "9c+",
  ]

  func convertGradeToString(_ grade: Components.Schemas.ClimbingGrade?) -> String {
    guard let grade = grade else { return "?" }

    let rawValue = grade.rawValue
    guard rawValue.hasPrefix("F_") else { return "?" }

    let withoutPrefix = rawValue.dropFirst(2)
    let gradeString = String(withoutPrefix).replacingOccurrences(of: "_plus", with: "+")

    return gradeString
  }

  func convertStringToGrade(_ grade: String) -> Components.Schemas.ClimbingGrade? {
    if grade == "?" {
      return .PROJECT
    }

    let formattedGrade = grade.replacingOccurrences(of: "+", with: "_plus")
    let enumCase = "F_\(formattedGrade)"

    return Components.Schemas.ClimbingGrade(rawValue: enumCase) ?? .PROJECT
  }

  func getGradeColor(_ grade: Components.Schemas.ClimbingGrade) -> Color {
    switch grade {
    case .F_4a, .F_4b, .F_4c:
      return Color.blue
    case .F_5a, .F_5b, .F_5c:
      return Color.green
    case .F_6a, .F_6a_plus, .F_6b, .F_6b_plus, .F_6c, .F_6c_plus:
      return Color.yellow
    case .F_7a, .F_7a_plus, .F_7b, .F_7b_plus, .F_7c, .F_7c_plus:
      return Color.orange
    case .F_8a, .F_8a_plus, .F_8b, .F_8b_plus, .F_8c, .F_8c_plus:
      return Color.red
    case .F_9a, .F_9a_plus, .F_9b, .F_9b_plus, .F_9c, .F_9c_plus:
      return Color.purple
    default:
      return Color.gray
    }
  }

  func getTextColor(_ grade: Components.Schemas.ClimbingGrade) -> Color {
    switch grade {
    case .F_4a, .F_4b, .F_4c:
      return Color.white
    default:
      return Color.black
    }
  }

  func sortedGrades() -> [Components.Schemas.ClimbingGrade] {
    climbingGrades.map { convertStringToGrade($0) }.compactMap { $0 }
  }
}
