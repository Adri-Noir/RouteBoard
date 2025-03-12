//
//  ClimbingGrades.swift
//  RouteBoard
//
//  Created with <3 on 04.07.2024..
//

import Foundation
import GeneratedClient
import SwiftUI

protocol ClimbingGrades {
  var climbingGrades: [String] { get }

  func convertGradeToString(_ grade: Components.Schemas.ClimbingGrade?) -> String

  func convertStringToGrade(_ grade: String) -> Components.Schemas.ClimbingGrade?

  func getGradeColor(_ grade: Components.Schemas.ClimbingGrade) -> Color

  func getTextColor(_ grade: Components.Schemas.ClimbingGrade) -> Color

  func sortedGrades() -> [Components.Schemas.ClimbingGrade]
}
