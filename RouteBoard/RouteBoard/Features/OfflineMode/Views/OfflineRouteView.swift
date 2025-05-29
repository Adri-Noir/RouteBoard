// Created with <3 on 20.05.2025.

import GeneratedClient
import SwiftData
import SwiftUI

struct OfflineRouteView: View {
  let routeId: String

  @Query private var routes: [DownloadedRoute]
  private var route: DownloadedRoute? { routes.first(where: { $0.id == routeId }) }

  @Environment(\.dismiss) var dismiss
  @State private var isFullscreenMode = false
  @State private var isPresentingRouteARView = false

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  var body: some View {
    if let route = route {
      ZStack(alignment: .bottom) {
        // Background image with gradient overlay
        OfflineRouteBackgroundView(
          route: route,
          isFullscreenMode: isFullscreenMode,
          onTap: {
            withAnimation(.easeInOut(duration: 0.3)) {
              isFullscreenMode.toggle()
            }
          }
        )

        // Bottom information section
        VStack(spacing: 0) {
          Spacer()
          HStack {
            OfflineRouteInfoView(route: route)
            Spacer()
          }
        }
        .padding(.bottom, safeAreaInsets.bottom)
        .opacity(isFullscreenMode ? 0 : 1)

        // Top navigation bar
        VStack {
          OfflineRouteNavigationBar(
            route: route,
            onRouteARView: { isPresentingRouteARView = true },
            onBack: { dismiss() }
          )
          Spacer()
        }
        .opacity(isFullscreenMode ? 0 : 1)

        // Exit fullscreen button
        if isFullscreenMode {
          ExitFullscreenButton(
            onExit: {
              withAnimation(.easeInOut(duration: 0.3)) {
                isFullscreenMode = false
              }
            }
          )
        }
      }
      .ignoresSafeArea()
      .fullScreenCover(isPresented: $isPresentingRouteARView) {
        RouteFinderView(routeId: route.id ?? "")
          .offlineMode(true)
      }
      .navigationBarHidden(true)
    } else {
      Text("Route not available offline.")
    }
  }
}

// MARK: - OfflineRouteBackgroundView
struct OfflineRouteBackgroundView: View {
  let route: DownloadedRoute
  let isFullscreenMode: Bool
  let onTap: () -> Void

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        if let photoUrl = route.photos.first?.combinedImagePhoto?.url,
          let url = URL(string: photoUrl)
        {
          AsyncImage(url: url) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          } placeholder: {
            PlaceholderImage()
              .frame(width: geometry.size.width, height: geometry.size.height)
          }
        } else {
          PlaceholderImage()
            .frame(width: geometry.size.width, height: geometry.size.height)
        }

        LinearGradient(
          gradient: Gradient(colors: [
            Color.black.opacity(isFullscreenMode ? 0 : 1),
            Color.black.opacity(isFullscreenMode ? 0 : 0.75),
            Color.black.opacity(isFullscreenMode ? 0 : 0.5),
            Color.black.opacity(0),
          ]),
          startPoint: .bottom,
          endPoint: .top
        )
        .animation(.easeInOut(duration: 0.3), value: isFullscreenMode)
      }
      .onTapGesture {
        onTap()
      }
    }
  }
}

// MARK: - OfflineRouteInfoView
struct OfflineRouteInfoView: View {
  let route: DownloadedRoute

  var climbingTypes: [UserClimbingType] {
    if let categories = route.routeCategories {
      return ClimbTypesConverter.convertComponentsClimbTypesToUserClimbingTypes(
        componentsClimbTypes: categories.climbTypes ?? []
      )
        + ClimbTypesConverter.convertComponentsRockTypesToUserClimbingTypes(
          componentsRockTypes: categories.rockTypes ?? []
        )
        + ClimbTypesConverter.convertComponentsHoldTypesToUserClimbingTypes(
          componentsHoldTypes: categories.holdTypes ?? []
        )
    }
    return []
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Route name
      Text(route.name ?? "Unknown Route")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding(.horizontal, ThemeExtension.horizontalPadding)

      // Location info
      OfflineRouteLocationSection(route: route)
        .padding(.horizontal, ThemeExtension.horizontalPadding)

      // Characteristics (optional, if you want to map routeType to UserClimbingType)
      if !climbingTypes.isEmpty {
        RouteCharacteristicsView(climbingTypes: climbingTypes)
      }

      // Description
      if let description = route.descriptionText, !description.isEmpty {
        VStack(alignment: .leading, spacing: 4) {
          Text("Description:")
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))
          Text(description)
            .font(.body)
            .foregroundColor(.white.opacity(0.9))
            .lineLimit(3)
        }
        .padding(.top, 4)
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.bottom, 10)
    .padding(.top, 20)
  }
}

// MARK: - OfflineRouteLocationSection
struct OfflineRouteLocationSection: View {
  let route: DownloadedRoute
  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 6) {
        Image(systemName: "mappin.circle.fill")
          .foregroundColor(.white.opacity(0.8))
        Text(route.cragName ?? "Unknown Crag")
          .font(.headline)
          .foregroundColor(.white.opacity(0.9))
      }
      HStack(spacing: 6) {
        Image(systemName: "square.grid.2x2.fill")
          .foregroundColor(.white.opacity(0.8))
        Text(route.sectorName ?? "Unknown Sector")
          .font(.headline)
          .foregroundColor(.white.opacity(0.9))
      }
      if let grade = route.grade {
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
      if let routeTypes = route.routeType, !routeTypes.isEmpty {
        HStack(spacing: 6) {
          Image(systemName: "figure.climbing")
            .foregroundColor(.white.opacity(0.8))
          Text("Type: ")
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))
          Text(
            routeTypes.compactMap { RouteTypeConverter.convertToString($0) }.joined(separator: ", ")
          )
          .font(.headline)
          .foregroundColor(.white)
        }
      }
      if let length = route.length {
        HStack(spacing: 6) {
          Image(systemName: "ruler")
            .foregroundColor(.white.opacity(0.8))
          Text("Length: \(length)m")
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))
        }
      }
    }
  }
}

// MARK: - OfflineRouteNavigationBar
struct OfflineRouteNavigationBar: View {
  let route: DownloadedRoute
  let onRouteARView: () -> Void
  let onBack: () -> Void

  var hasPhotos: Bool {
    route.photos.first?.combinedImagePhoto?.url != nil
  }

  var body: some View {
    HStack {
      Button(action: onBack) {
        Image(systemName: "chevron.left")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(12)
          .background(Color.black.opacity(0.6))
          .clipShape(Circle())
      }
      Spacer()
      if hasPhotos {
        Button(action: onRouteARView) {
          Image(systemName: "arkit")
            .foregroundColor(.white)
            .font(.system(size: 18, weight: .semibold))
            .padding(12)
            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
        }
      }
    }
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.top, 60)
  }
}
