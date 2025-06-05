// Created with <3 on 16.03.2025.

import Charts
import GeneratedClient
import SwiftUI

struct ClimbingGradesGraphView: View {
  let climbingGradeAscentCount: [Components.Schemas.GradeCountDto]?
  @EnvironmentObject var authViewModel: AuthViewModel

  var body: some View {
    let rawGradeData: [(grade: String, count: Int, color: Color)] = (climbingGradeAscentCount ?? [])
      .compactMap { dto in
        if let grade = dto.climbingGrade, let count = dto.count {
          let gradeString = authViewModel.getGradeSystem().convertGradeToString(grade)
          let color = authViewModel.getGradeSystem().getGradeColor(grade)
          return (grade: gradeString, count: Int(count), color: color)
        }
        return nil
      }

    let groupedGrades = rawGradeData.reduce(into: [String: (count: Int, color: Color)]()) {
      dict, entry in
      if let existing = dict[entry.grade] {
        dict[entry.grade] = (count: existing.count + entry.count, color: entry.color)
      } else {
        dict[entry.grade] = (count: entry.count, color: entry.color)
      }
    }

    let gradeStats = groupedGrades.map {
      (grade: $0.key, count: $0.value.count, color: $0.value.color)
    }
    .sorted { $0.grade < $1.grade }

    return VStack(alignment: .leading, spacing: 12) {
      Text("Climbing Grades Distribution")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      if gradeStats.isEmpty {
        Text(
          "No grade data available"
        )
        .foregroundColor(Color.newTextColor.opacity(0.7))
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 200)
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          Chart {
            ForEach(gradeStats, id: \.grade) { stat in
              BarMark(
                x: .value("Grade", stat.grade),
                y: .value("Count", stat.count)
              )
              .foregroundStyle(stat.color)
              .annotation(position: .top) {
                Text("\(stat.count)")
                  .font(.caption2)
                  .foregroundColor(Color.newTextColor)
              }
            }
          }
          .frame(height: 250)
          .frame(
            width: max(CGFloat(gradeStats.count * 40), UIScreen.main.bounds.width - 80)
          )
          .chartYScale(domain: 0...(gradeStats.map { $0.count }.max() ?? 0) + 5)
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }
}
