// Created with <3 on 16.03.2025.

import Charts
import GeneratedClient
import SwiftUI

struct ClimbingStatsGraphView: View {
  let climbingStats: [ClimbingStat]
  let selectedAscentType: Components.Schemas.RouteType?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Performance Graph")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      if climbingStats.isEmpty {
        Text("No data available for graph")
          .foregroundColor(Color.newTextColor.opacity(0.7))
          .padding()
          .frame(maxWidth: .infinity, alignment: .center)
          .frame(height: 200)
      } else {
        VStack(alignment: .leading, spacing: 12) {
          if let selectedType = selectedAscentType {
            Text(
              "Filtered by: \(RouteTypeConverter.convertToString(selectedType) ?? "")"
            )
            .font(.subheadline)
            .foregroundColor(Color.newTextColor.opacity(0.7))
          }

          Chart {
            ForEach(climbingStats) { stat in
              BarMark(
                x: .value("Type", stat.type),
                y: .value("Count", stat.count)
              )
              .foregroundStyle(stat.color)
            }
          }
          .frame(height: 200)
          .chartYScale(domain: 0...(climbingStats.map { $0.count }.max() ?? 0) + 10)
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }
}
