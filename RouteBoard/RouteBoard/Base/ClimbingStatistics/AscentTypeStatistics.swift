// Created with <3 on 16.03.2025.

import GeneratedClient
import SwiftUI

struct ClimbingStat: Identifiable {
  let id = UUID()
  let type: String
  let count: Int
  let color: Color
}

class AscentTypeStatistics {

  static func calculateAscentStats(
    routeTypeAscentCount: [Components.Schemas.RouteTypeAscentCountDto]?,
    selectedAscentType: Components.Schemas.RouteType?
  ) -> [ClimbingStat] {
    guard let routeTypeAscentCount = routeTypeAscentCount,
      !routeTypeAscentCount.isEmpty
    else {
      return []
    }

    var stats: [ClimbingStat] = []

    // Filter by selected ascent type
    if let selectedType = selectedAscentType {
      // Find the route type that matches the selected type
      if let routeTypeData = routeTypeAscentCount.first(where: {
        $0.routeType == selectedType
      }) {
        // Extract ascent counts for this route type
        if let ascentCounts = routeTypeData.ascentCount {
          for ascentCount in ascentCounts {
            if let ascentType = ascentCount.ascentType, let count = ascentCount.count,
              count > 0
            {
              let ascentTypeString = AscentTypeConverter.convertToString(ascentType) ?? "Unknown"
              let color: Color
              switch ascentTypeString {
              case "Onsight": color = .green
              case "Flash": color = .blue
              case "Redpoint": color = .red
              case "Aid": color = .orange
              default: color = .gray
              }
              stats.append(ClimbingStat(type: ascentTypeString, count: Int(count), color: color))
            }
          }
        }
      }
    } else {
      // Aggregate all ascent types
      var ascentCounts: [String: Int] = [:]

      // Iterate through all route types
      for routeTypeData in routeTypeAscentCount {
        // Add up the counts for each ascent type
        if let ascentCountArray = routeTypeData.ascentCount {
          for ascentCount in ascentCountArray {
            if let ascentType = ascentCount.ascentType, let count = ascentCount.count {
              let ascentTypeString = AscentTypeConverter.convertToString(ascentType) ?? "Unknown"
              ascentCounts[ascentTypeString] = (ascentCounts[ascentTypeString] ?? 0) + Int(count)
            }
          }
        }
      }

      // Convert to ClimbingStat array
      for (type, count) in ascentCounts {
        if count > 0 {
          let color: Color
          switch type {
          case "Onsight": color = .green
          case "Flash": color = .blue
          case "Redpoint": color = .red
          case "Aid": color = .orange
          default: color = .gray
          }
          stats.append(ClimbingStat(type: type, count: count, color: color))
        }
      }
    }

    // Define a consistent order for ascent types to ensure stable sorting
    let typeOrder = ["Onsight", "Flash", "Redpoint", "Aid"]

    // Sort by count (descending) first, then by type order for stable sorting when counts are equal
    let sortedStats = stats.sorted { (a, b) -> Bool in
      if a.count != b.count {
        return a.count > b.count
      } else {
        // If counts are equal, sort by predefined order
        let aIndex = typeOrder.firstIndex(of: a.type) ?? Int.max
        let bIndex = typeOrder.firstIndex(of: b.type) ?? Int.max
        return aIndex < bIndex
      }
    }

    return sortedStats
  }
}
