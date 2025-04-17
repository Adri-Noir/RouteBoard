// Created with <3 on 22.03.2025.

import GeneratedClient
import SwiftUI

struct RouteTabView: View {
  let routes: [SectorRouteDto]

  var body: some View {
    TabView {
      ForEach(routes, id: \.id) { route in
        RouteCardFullscreen(route: route)
      }
    }
    .tabViewStyle(PageTabViewStyle())
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    .frame(height: 500)
    .animation(.easeInOut, value: routes)
    .transition(.opacity)
  }
}

struct RouteCardFullscreen: View {
  let route: SectorRouteDto

  var body: some View {
    RouteLink(routeId: route.id) {
      ZStack(alignment: .bottom) {
        // Background image
        GeometryReader { geometry in
          if let photos = route.routePhotos, !photos.isEmpty,
            let imageUrl = photos.first?.combinedPhoto?.url,
            let url = URL(string: imageUrl)
          {
            AsyncImage(url: url) { phase in
              switch phase {
              case .success(let image):
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: geometry.size.width, height: geometry.size.height)
              case .failure:
                PlaceholderImage()
              default:
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: Color.newTextColor))
              }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
          } else {
            PlaceholderImage()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .clipped()
          }
        }

        // Gradient overlay
        LinearGradient(
          gradient: Gradient(
            colors: [
              Color.black.opacity(0.0),
              Color.black.opacity(0.5),
              Color.black.opacity(0.8),
            ]
          ),
          startPoint: .top,
          endPoint: .bottom
        )

        // Route info
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(route.name ?? "Unnamed Route")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

              if let description = route.description, !description.isEmpty {
                Text(description)
                  .font(.subheadline)
                  .foregroundColor(.white.opacity(0.8))
                  .lineLimit(2)
                  .multilineTextAlignment(.leading)
              }
            }

            Spacer()

            if let grade = route.grade {
              GradeTagLarge(grade: grade)
            }
          }

          HStack(spacing: 20) {
            RouteInfoItemLight(
              icon: "ruler", label: route.length != nil ? "\(route.length!) m" : "Unknown")

            if let routeType = route.routeType {
              RouteInfoItemLight(icon: "arrow.up", label: routeType.first?.rawValue ?? "Unknown")
            }

            if let ascentsCount = route.ascentsCount {
              RouteInfoItemLight(
                icon: "checkmark.circle",
                label: "\(ascentsCount) ascent\(ascentsCount == 1 ? "" : "s")"
              )
            }

            Spacer()
          }

          if let categories = route.routeCategories,
            (categories.climbTypes != nil && !categories.climbTypes!.isEmpty)
              || (categories.rockTypes != nil && !categories.rockTypes!.isEmpty)
              || (categories.holdTypes != nil && !categories.holdTypes!.isEmpty)
          {
            HStack(spacing: 8) {
              if let climbTypes = categories.climbTypes {
                ForEach(Array(climbTypes.prefix(1)), id: \.self) { category in
                  let climbingType =
                    ClimbTypesConverter.convertComponentsClimbTypesToUserClimbingTypes(
                      componentsClimbTypes: [category]
                    ).first

                  Text(climbingType?.rawValue ?? category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.newPrimaryColor.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
              }

              if let rockTypes = categories.rockTypes {
                ForEach(Array(rockTypes.prefix(1)), id: \.self) { category in
                  let rockType =
                    ClimbTypesConverter.convertComponentsRockTypesToUserClimbingTypes(
                      componentsRockTypes: [category]
                    ).first

                  Text(rockType?.rawValue ?? category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.newPrimaryColor.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
              }

              if let holdTypes = categories.holdTypes {
                ForEach(Array(holdTypes.prefix(1)), id: \.self) { category in
                  let holdType =
                    ClimbTypesConverter.convertComponentsHoldTypesToUserClimbingTypes(
                      componentsHoldTypes: [category]
                    ).first

                  Text(holdType?.rawValue ?? category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.newPrimaryColor.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
              }

              let totalCount =
                (categories.climbTypes?.count ?? 0) + (categories.rockTypes?.count ?? 0)
                + (categories.holdTypes?.count ?? 0)
              let displayedCount =
                min(1, categories.climbTypes?.count ?? 0) + min(1, categories.rockTypes?.count ?? 0)
                + min(1, categories.holdTypes?.count ?? 0)

              if totalCount > displayedCount {
                Text("+\(totalCount - displayedCount)")
                  .font(.caption)
                  .foregroundColor(.white)
                  .padding(.horizontal, 10)
                  .padding(.vertical, 5)
                  .background(Color.gray.opacity(0.7))
                  .clipShape(RoundedRectangle(cornerRadius: 12))
              }
            }
            .frame(height: 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
            .padding(.top, -8)
          }
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
        .padding(.bottom, 30)
      }
      .cornerRadius(16)
      .padding(.horizontal, ThemeExtension.horizontalPadding)
      .padding(.vertical, 10)
    }
  }
}

struct GradeTagLarge: View {
  @EnvironmentObject private var authViewModel: AuthViewModel

  let grade: Components.Schemas.ClimbingGrade

  var body: some View {
    Text(authViewModel.getGradeSystem().convertGradeToString(grade))
      .font(.system(.title3, design: .rounded))
      .fontWeight(.bold)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .fill(gradeColor(for: authViewModel.getGradeSystem().convertGradeToString(grade)))
      )
      .foregroundColor(.white)
  }

  private func gradeColor(for gradeString: String) -> Color {
    // Simple color mapping based on grade difficulty
    if gradeString.contains("3") || gradeString.contains("4") {
      return .green
    } else if gradeString.contains("5") || gradeString.contains("6a") || gradeString.contains("6b")
    {
      return .blue
    } else if gradeString.contains("6c") || gradeString.contains("7a") || gradeString.contains("7b")
    {
      return .orange
    } else if gradeString.contains("7c") || gradeString.contains("8") || gradeString.contains("9") {
      return .red
    } else {
      return .gray
    }
  }
}
