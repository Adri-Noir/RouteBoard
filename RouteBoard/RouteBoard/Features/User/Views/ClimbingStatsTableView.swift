// Created with <3 on 16.03.2025.

import GeneratedClient
import SwiftUI

struct ClimbingStatsTableView: View {
  let climbingStats: [ClimbingStat]
  let selectedAscentType: Components.Schemas.RouteType?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Climbing Stats")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      if let selectedType = selectedAscentType {
        Text(
          "Filtered by: \(RouteTypeConverter.convertToString(selectedType) ?? selectedType.rawValue)"
        )
        .font(.subheadline)
        .foregroundColor(Color.newTextColor.opacity(0.7))
      }

      VStack(spacing: 0) {
        if climbingStats.isEmpty {
          Text("No climbing stats available")
            .foregroundColor(Color.newTextColor.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
          HStack {
            Text("Type")
              .fontWeight(.bold)
              .frame(width: 100, alignment: .leading)
              .foregroundColor(Color.newTextColor)
            Text("Count")
              .fontWeight(.bold)
              .frame(maxWidth: .infinity, alignment: .trailing)
              .foregroundColor(Color.newTextColor)
          }
          .padding(.vertical, 8)
          .background(Color.white.opacity(0.9))

          ForEach(climbingStats.indices, id: \.self) { index in
            VStack(spacing: 0) {
              HStack {
                Text(climbingStats[index].type)
                  .frame(width: 100, alignment: .leading)
                  .foregroundColor(Color.newTextColor)
                Text("\(climbingStats[index].count)")
                  .frame(maxWidth: .infinity, alignment: .trailing)
                  .foregroundColor(Color.newTextColor)
              }
              .padding(.vertical, 8)
              .background(Color.white.opacity(0.7))

              if index < climbingStats.count - 1 {
                Divider()
              }
            }
          }

          HStack {
            Text("Total")
              .fontWeight(.bold)
              .frame(width: 100, alignment: .leading)
              .foregroundColor(Color.newTextColor)
            Text("\(climbingStats.reduce(0) { $0 + $1.count })")
              .fontWeight(.bold)
              .frame(maxWidth: .infinity, alignment: .trailing)
              .foregroundColor(Color.newTextColor)
          }
          .padding(.vertical, 8)
          .background(Color.white.opacity(0.9))
        }
      }
      .frame(minHeight: 100)
      .cornerRadius(8)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }
}
