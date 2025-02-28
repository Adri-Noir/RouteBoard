//
//  FrenchClimbingGrades.swift
//  RouteBoard
//
//  Created with <3 on 04.07.2024..
//

import Foundation
import GeneratedClient

class FrenchClimbingGrades: ClimbingGrades {

  var climbingGrades: [String] = [
    "?", "4a", "4b", "4c", "5a", "5b", "5c", "6a", "6a+", "6b", "6b+", "6c", "6c+", "7a", "7a+",
    "7b",
    "7b+", "7c", "7c+", "8a", "8a+", "8b", "8b+", "8c", "8c+", "9a", "9a+", "9b", "9b+", "9c",
    "9c+",
  ]

  func convertGradeToString(_ grade: Components.Schemas.ClimbingGrade?) -> String {
    guard let grade = grade else { return "?" }

    let rawGrade = grade.rawValue.split(separator: "_").last ?? ""
    let gradeString = rawGrade.replacingOccurrences(of: "plus", with: "+")

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
}
