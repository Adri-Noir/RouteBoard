// Created with <3 on 20.03.2025.

import GeneratedClient
import SwiftUI

struct RouteLocationSection: View {
  let route: RouteDetails?
  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 6) {
        Image(systemName: "mountain.2.circle.fill")
          .foregroundColor(.white.opacity(0.8))

        CragLink(cragId: route?.cragId ?? "") {
          Text(route?.cragName ?? "Unknown Crag")
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))
        }
      }

      HStack(spacing: 6) {
        Image(systemName: "square.grid.2x2.fill")
          .foregroundColor(.white.opacity(0.8))

        SectorLink(sectorId: route?.sectorId) {
          Text(route?.sectorName ?? "Unknown Sector")
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))
        }
      }

      if let route = route, let grade = route.grade {
        HStack(spacing: 6) {
          Image(systemName: "chart.bar.fill")
            .foregroundColor(.white.opacity(0.8))

          Text("Grade: ")
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))

          Text(authViewModel.getGradeSystem().convertGradeToString(grade))
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
        }
      }

      if let route = route, let routeTypes = route.routeType, !routeTypes.isEmpty {
        HStack(spacing: 6) {
          Image(systemName: "figure.climbing")
            .foregroundColor(.white.opacity(0.8))

          Text("Type: ")
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))

          Text(
            routeTypes.compactMap { RouteTypeConverter.convertToString($0) }.joined(
              separator: ", ")
          )
          .font(.headline)
          .foregroundColor(.white)
        }
      }
    }
  }
}
