//
//  GradesGraphModel.swift
//  RouteBoard
//
//  Created with <3 on 04.07.2024..
//

import Foundation
import GeneratedClient
import SwiftUI

struct Grade: Identifiable {
  let grade: String

  var id: String { grade }
}

struct GradeCount: Identifiable {
  let grade: String
  let count: Int

  var id: String { grade }
}

struct GradeColor: Identifiable {
  let grade: String
  let color: Color
  let textColor: Color

  var id: String { grade }
}

class GradesGraphModel {
  var grades: [GradeCount] = []
  var gradeStandard: ClimbingGrades = FrenchClimbingGrades()

  init(grades: [GradeCount], gradeStandard: ClimbingGrades = FrenchClimbingGrades()) {
    self.grades = grades
    self.gradeStandard = gradeStandard
  }

  init(sector: SectorDetails?, gradeStandard: ClimbingGrades = FrenchClimbingGrades()) {
    self.gradeStandard = gradeStandard
    addGradesFromSector(sector: sector)
  }

  private func addGradesFromSector(sector: SectorDetails?) {
    guard let routes = sector?.routes else {
      return
    }

    let gradesArray = routes.reduce(into: [String: Int]()) { result, route in
      if let grade = route.grade {
        result[gradeStandard.convertGradeToString(grade), default: 0] += 1
      }
    }
    .map { grade, count in
      GradeCount(grade: grade, count: count)
    }

    self.grades.append(contentsOf: gradesArray)
  }

  var gradesMap: [String: GradeCount] {
    var map = [String: GradeCount]()

    grades.forEach { grade in
      map[grade.grade] = grade

    }

    return map
  }

  var sortedGradesList: [GradeCount] {
    return gradeStandard.climbingGrades.compactMap { grade in
      if gradesMap[grade] != nil {
        return gradesMap[grade]
      } else {
        return nil
      }
    }
  }

  var gradeColor: [String: GradeColor] {
    Dictionary(
      uniqueKeysWithValues: gradeStandard.climbingGrades.enumerated().map { index, grade in
        let fraction =
          Double(Color.gradesGraphGradient.count) / Double(gradeStandard.climbingGrades.count)
        let correctedIndex = Int(fraction * Double(index))
        let color = Color.gradesGraphGradient[correctedIndex]
        return (
          grade,
          GradeColor(
            grade: grade, color: color,
            textColor: .white)
        )
      })
  }

  var maxCount: Int {
    var max: Int = 0
    grades.forEach { grade in
      if grade.count > max {
        max = grade.count
      }
    }

    return max
  }

  var minGrade: String {
    if sortedGradesList.isEmpty {
      return "?"
    }

    return sortedGradesList[0].grade
  }

  var maxGrade: String {
    if sortedGradesList.isEmpty {
      return "?"
    }

    return sortedGradesList[sortedGradesList.count - 1].grade
  }

  var medianGrade: String {
    if sortedGradesList.isEmpty {
      return "?"
    }

    let middle = (sortedGradesList.count - 1) / 2
    return sortedGradesList[middle].grade
  }
}
