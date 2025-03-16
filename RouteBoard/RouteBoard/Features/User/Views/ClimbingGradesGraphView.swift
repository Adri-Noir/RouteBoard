// Created with <3 on 16.03.2025.

import Charts
import GeneratedClient
import SwiftUI

struct ClimbingGradesGraphView: View {
  let climbingGradesStats: [GradeStat]
  let selectedAscentType: Components.Schemas.RouteType?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Climbing Grades Distribution")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      if let selectedType = selectedAscentType {
        Text(
          "Filtered by: \(RouteTypeConverter.convertToString(selectedType) ?? selectedType.rawValue)"
        )
        .font(.subheadline)
        .foregroundColor(Color.newTextColor.opacity(0.7))
      }

      if climbingGradesStats.isEmpty {
        Text(
          "No grade data available\(selectedAscentType != nil ? " for \(RouteTypeConverter.convertToString(selectedAscentType) ?? "")" : "")"
        )
        .foregroundColor(Color.newTextColor.opacity(0.7))
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 200)
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          Chart {
            ForEach(climbingGradesStats) { stat in
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
            width: max(CGFloat(climbingGradesStats.count * 40), UIScreen.main.bounds.width - 80)
          )
          .chartYScale(domain: 0...(climbingGradesStats.map { $0.count }.max() ?? 0) + 5)
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }
}
