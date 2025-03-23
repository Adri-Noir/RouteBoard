// Created with <3 on 22.03.2025.

import GeneratedClient
import SwiftUI

struct AllSectorsRoutesView: View {
  let sectors: [SectorDetailedDto]
  let viewMode: RouteViewMode
  let selectedGrade: Components.Schemas.ClimbingGrade?
  let onSectorSelect: (String) -> Void

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        ForEach(sectors, id: \.id) { sector in
          SectorRoutesSection(
            sector: sector,
            viewMode: viewMode,
            selectedGrade: selectedGrade,
            onSectorSelect: onSectorSelect
          )
          .padding(.vertical, 8)
        }
      }
      .padding(.vertical, 10)
    }
  }
}

struct SectorRoutesSection: View {
  let sector: SectorDetailedDto
  let viewMode: RouteViewMode
  let selectedGrade: Components.Schemas.ClimbingGrade?
  let onSectorSelect: (String) -> Void

  private var filteredRoutes: [SectorRouteDto] {
    sector.routes?.filter { route in
      if let selectedGrade = selectedGrade {
        return route.grade == selectedGrade
      }
      return true
    } ?? []
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // Sector header
      HStack {
        Text(sector.name ?? "Unnamed Sector")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(Color.newTextColor)

        Spacer()

        Button(action: {
          onSectorSelect(sector.id)
        }) {
          HStack(spacing: 4) {
            Text("View")
              .font(.subheadline)
              .foregroundColor(Color.newPrimaryColor)

            Image(systemName: "chevron.right")
              .font(.caption)
              .foregroundColor(Color.newPrimaryColor)
          }
        }
      }
      .padding(.horizontal, 20)

      // Sector routes
      if filteredRoutes.isEmpty {
        Text(
          selectedGrade != nil
            ? "No routes with selected grade in this sector" : "No routes in this sector"
        )
        .font(.subheadline)
        .foregroundColor(Color.newTextColor.opacity(0.7))
        .padding(.horizontal, 20)
        .padding(.bottom, 5)
      } else {
        // Routes section
        if viewMode == .tabs {
          RouteTabView(routes: filteredRoutes)
        } else {
          VStack(spacing: 8) {
            ForEach(filteredRoutes, id: \.id) { route in
              RouteCardList(route: route)
            }
          }
        }
      }

      Divider()
        .padding(.top, 8)
    }
  }
}

struct RouteCardList: View {
  let route: SectorRouteDto
  private let gradeConverter = FrenchClimbingGrades()

  var body: some View {
    RouteLink(routeId: route.id) {
      HStack(spacing: 12) {
        // Route thumbnail
        if let photos = route.routePhotos, !photos.isEmpty, let imageUrl = photos.first?.image?.url,
          let url = URL(string: imageUrl)
        {
          AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
              Rectangle()
                .fill(Color.gray.opacity(0.2))
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            case .failure:
              PlaceholderImage()
            @unknown default:
              EmptyView()
            }
          }
          .frame(width: 100, height: 150)
          .cornerRadius(8)
          .clipped()
        } else {
          PlaceholderImage()
            .frame(width: 100, height: 150)
            .cornerRadius(8)
        }

        // Route info
        VStack(alignment: .leading, spacing: 4) {
          Text(route.name ?? "Unnamed Route")
            .font(.headline)
            .foregroundColor(Color.newTextColor)
            .lineLimit(1)

          if let routeType = route.routeType {
            RouteInfoItem(icon: "arrow.up", label: routeType.first?.rawValue ?? "Unknown")
          }

          RouteInfoItem(
            icon: "ruler", label: route.length != nil ? "\(route.length!) m" : "Unknown")

          if let ascentsCount = route.ascentsCount {
            RouteInfoItem(
              icon: "checkmark.circle",
              label: "\(ascentsCount) ascent\(ascentsCount == 1 ? "" : "s")"
            )
          }
        }

        Spacer()

        // Grade
        if let grade = route.grade {
          GradeTag(grade: grade)
        }
      }
      .padding()
      .background(Color.white)
      .cornerRadius(12)
      .padding(.horizontal, 20)
    }
  }
}

struct GradeTag: View {
  @EnvironmentObject private var authViewModel: AuthViewModel

  let grade: Components.Schemas.ClimbingGrade

  var body: some View {
    Text(authViewModel.getGradeSystem().convertGradeToString(grade))
      .font(.system(.subheadline, design: .rounded))
      .fontWeight(.bold)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(
        Capsule()
          .fill(authViewModel.getGradeSystem().getGradeColor(grade))
      )
      .foregroundColor(.white)
  }
}
