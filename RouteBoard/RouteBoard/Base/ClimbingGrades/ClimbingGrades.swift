//
//  ClimbingGrades.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 04.07.2024..
//

import Foundation
import GeneratedClient

protocol ClimbingGrades {
  var climbingGrades: [String] { get }

  func convertGradeToString(_ grade: Components.Schemas.ClimbingGrade?) -> String
}
