//
//  ClimbingGrades.swift
//  RouteBoard
//
//  Created with <3 on 04.07.2024..
//

import Foundation
import GeneratedClient

protocol ClimbingGrades {
  var climbingGrades: [String] { get }

  func convertGradeToString(_ grade: Components.Schemas.ClimbingGrade?) -> String

  func convertStringToGrade(_ grade: String) -> Components.Schemas.ClimbingGrade?
}
