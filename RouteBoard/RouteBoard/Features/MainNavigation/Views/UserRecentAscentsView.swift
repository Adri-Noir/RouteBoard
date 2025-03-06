// Created with <3 on 23.02.2025.

import GeneratedClient
import SwiftUI

struct UserRecentAscentsView: View {
  @EnvironmentObject private var authViewModel: AuthViewModel
  @State private var recentAscents: [UserRecentAscents] = []
  @State private var isLoading = false
  @State private var showAllAscents = false
  @State private var errorMessage: String? = nil

  private let userRecentAscentsClient = UserRecentAscentsClient()

  func fetchRecentAscents() async {
    isLoading = true
    recentAscents = await userRecentAscentsClient.call(
      (), authViewModel.getAuthData(), { errorMessage = $0 })
    isLoading = false
  }

  var body: some View {
    VStack(spacing: 12) {
      // Header
      HStack(alignment: .center) {
        HStack(spacing: 8) {
          Image(systemName: "figure.climbing")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color.white)

          Text("Recent Ascents")
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(Color.white)
        }

        Spacer()

        Button(action: {
          showAllAscents = true
        }) {
          Text("Show All")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }
      .padding(.horizontal, 20)

      // Content
      Group {
        if isLoading && recentAscents.isEmpty {
          loadingView
        } else if recentAscents.isEmpty {
          emptyStateView
        } else {
          recentAscentsScrollView
        }
      }
    }
    .task {
      await fetchRecentAscents()
    }
    .onDisappear {
      userRecentAscentsClient.cancel()
    }
    .alert(message: $errorMessage)
  }

  private var loadingView: some View {
    VStack(spacing: 12) {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .scaleEffect(1.2)

      Text("Loading your ascents...")
        .font(.subheadline)
        .foregroundColor(.white.opacity(0.7))
    }
    .frame(maxWidth: .infinity, minHeight: 225)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.08))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    )
    .padding(.horizontal, 20)
  }

  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Image(systemName: "mountain.2")
        .font(.system(size: 40))
        .foregroundColor(.white.opacity(0.5))

      Text("No recent ascents")
        .font(.headline)
        .foregroundColor(.white.opacity(0.8))

      Text("Your climbing achievements will appear here")
        .font(.subheadline)
        .foregroundColor(.white.opacity(0.6))
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
    .frame(maxWidth: .infinity, minHeight: 225)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.08))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    )
    .padding(.horizontal, 20)
  }

  private var recentAscentsScrollView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 20) {
        ForEach(recentAscents, id: \.id) { route in
          RouteLink(routeId: .constant(route.id)) {
            routeCard(for: route)
          }
          .scrollTransition { content, phase in
            content
              .opacity(phase.isIdentity ? 1 : 0.5)
              .scaleEffect(phase.isIdentity ? 1 : 0.95)
          }
        }
      }
      .scrollTargetLayout()
      .padding(.horizontal, 20)
      .padding(.bottom, 8)
    }
    .scrollTargetBehavior(.viewAligned)
  }

  private func routeCard(for route: UserRecentAscents) -> some View {
    ZStack(alignment: .bottomLeading) {
      // Background image
      routeBackgroundImage(for: route)

      // Gradient overlay
      LinearGradient(
        gradient: Gradient(colors: [
          Color.black.opacity(0.9),
          Color.black.opacity(0.4),
          Color.black.opacity(0.2),
        ]),
        startPoint: .bottom,
        endPoint: .top
      )

      // Content
      VStack(alignment: .leading, spacing: 0) {
        // Top section with grade
        HStack {
          Spacer()
          if let grade = route.grade {
            Text(authViewModel.getGradeSystem().convertGradeToString(grade))
              .font(.system(size: 14, weight: .bold))
              .foregroundColor(.white)
              .padding(.horizontal, 10)
              .padding(.vertical, 5)
              .background(Color.black.opacity(0.6))
              .clipShape(RoundedRectangle(cornerRadius: 8))
          }
        }
        .padding([.top, .horizontal], 12)

        Spacer()

        // Route name
        Text(route.name ?? "Unknown Route")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(.white)
          .lineLimit(1)
          .padding(.horizontal, 16)

        // Location info
        VStack(alignment: .leading, spacing: 6) {
          HStack(spacing: 6) {
            Image(systemName: "mappin.circle.fill")
              .font(.system(size: 12))
              .foregroundColor(.white.opacity(0.8))

            Text(route.cragName ?? "Unknown Crag")
              .font(.subheadline)
              .foregroundColor(.white.opacity(0.9))
              .lineLimit(1)
          }

          HStack(spacing: 6) {
            Image(systemName: "square.grid.2x2.fill")
              .font(.system(size: 12))
              .foregroundColor(.white.opacity(0.8))

            Text(route.sectorName ?? "Unknown Sector")
              .font(.subheadline)
              .foregroundColor(.white.opacity(0.9))
              .lineLimit(1)
          }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .padding(.top, 4)
      }
    }
    .frame(width: 280, height: 200)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    // .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
  }

  private func routeBackgroundImage(for route: UserRecentAscents) -> some View {
    Group {
      if let firstPhoto = route.routePhotos?.first?.image?.url, !firstPhoto.isEmpty {
        AsyncImage(url: URL(string: firstPhoto)) { phase in
          switch phase {
          case .empty:
            Color.gray.opacity(0.3)
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          case .failure:
            Image("TestingSamples/limski/pikachu")
              .resizable()
              .aspectRatio(contentMode: .fill)
          @unknown default:
            Image("TestingSamples/limski/pikachu")
              .resizable()
              .aspectRatio(contentMode: .fill)
          }
        }
      } else {
        defaultRouteImage
      }
    }
    .frame(width: 280, height: 200)
  }

  private var defaultRouteImage: some View {
    Image("TestingSamples/limski/pikachu")
      .resizable()
      .aspectRatio(contentMode: .fill)
  }
}
