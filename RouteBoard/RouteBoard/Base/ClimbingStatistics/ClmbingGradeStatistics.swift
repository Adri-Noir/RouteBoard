// Created with <3 on 16.03.2025.

import GeneratedClient
import SwiftUI

struct GradeStat: Identifiable {
  let id = UUID()
  let grade: String
  let count: Int
  let color: Color
}

class ClimbingGradeStatistics {

  static func calculateGradeStats(
    climbingGradeAscentCount: [Components.Schemas.ClimbingGradeAscentCountDto]?,
    selectedAscentType: Components.Schemas.RouteType?,
    gradeSystem: ClimbingGrades
  ) -> [GradeStat] {
    // Return empty array if no data available
    guard let climbingGradeAscentCount = climbingGradeAscentCount,
      !climbingGradeAscentCount.isEmpty
    else {
      return []
    }

    var stats: [GradeStat] = []

    // Filter by selected ascent type if not "All"
    let filteredGradeData: [Components.Schemas.ClimbingGradeAscentCountDto]
    if let selectedType = selectedAscentType {
      filteredGradeData = climbingGradeAscentCount.filter {
        $0.routeType?.rawValue == selectedType.rawValue
      }

      // If no data for the selected route type, return empty array
      if filteredGradeData.isEmpty {
        return []
      }
    } else {
      filteredGradeData = climbingGradeAscentCount
    }

    // Create a dictionary to aggregate counts for the same grade
    var gradeCounts: [String: (count: Int, color: Color)] = [:]

    // Process the climbing grades data
    for gradeData in filteredGradeData {
      if let gradeCountArray = gradeData.gradeCount {
        for gradeCount in gradeCountArray {
          if let grade = gradeCount.climbingGrade, let count = gradeCount.count, count > 0 {
            // Format the grade label for display
            let displayLabel = gradeSystem.convertGradeToString(grade)

            // Determine color based on grade difficulty
            let color: Color
            if displayLabel.contains("9") {
              color = .red
            } else if displayLabel.contains("8") {
              color = .orange
            } else if displayLabel.contains("7") {
              color = .yellow
            } else if displayLabel.contains("6") {
              color = .green
            } else {
              color = .blue
            }

            // Add or update the count in our dictionary
            if let existing = gradeCounts[displayLabel] {
              gradeCounts[displayLabel] = (count: existing.count + Int(count), color: color)
            } else {
              gradeCounts[displayLabel] = (count: Int(count), color: color)
            }
          }
        }
      }
    }

    for (grade, data) in gradeCounts {
      stats.append(GradeStat(grade: grade, count: data.count, color: data.color))
    }

    let sortedStats = stats.sorted { (a, b) -> Bool in
      let aIndex = gradeSystem.climbingGrades.firstIndex(of: a.grade) ?? Int.max
      let bIndex = gradeSystem.climbingGrades.firstIndex(of: b.grade) ?? Int.max
      return aIndex < bIndex
    }

    return sortedStats
  }
}
