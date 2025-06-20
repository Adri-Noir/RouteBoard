// Created with <3 on 23.02.2025.

import GeneratedClient
import SwiftUI

struct ExploreView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var exploreCacheClient: ExploreCacheClient
  @EnvironmentObject var navigationManager: NavigationManager

  @State private var currentTab: String?
  let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

  @State private var exploreItems: [ExploreDto] = []
  @State private var isLoading = false
  @State private var errorMessage: String? = nil
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Image(systemName: "map")
          .foregroundColor(Color.white)
        Text("Explore")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(Color.white)

        Spacer()

        Button(action: {
          navigationManager.pushView(.map)
        }) {
          HStack {
            Image(systemName: "globe")
              .foregroundColor(Color.white)
            Text("Explore")
              .foregroundColor(Color.white)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Color.white.opacity(0.1))
          .cornerRadius(8)
        }
      }
      .padding(.horizontal, ThemeExtension.horizontalPadding)

      if isLoading {
        loadingView
      } else if exploreItems.isEmpty {
        noResultsView
      } else {
        exploreItemsScrollView
      }
    }
    .task {
      await fetchExploreData()
    }
  }

  private var exploreItemsScrollView: some View {
    ScrollView(.horizontal) {
      LazyHStack(spacing: 16) {
        ForEach(exploreItems, id: \.id) { item in
          GeometryReader { geometry in
            CragLink(cragId: item.cragId ?? "") {
              ExploreItemCard(item: item, geometry: geometry)
            }
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
          .containerRelativeFrame(.horizontal, count: 1, spacing: 0, alignment: .center)
          .padding(.vertical, 10)
          .id(item.id)
        }
      }
      .scrollTargetLayout()
    }
    .scrollPosition(id: $currentTab)
    .scrollTargetBehavior(.viewAligned)
    .scrollIndicators(.hidden)
    .frame(height: 250)
    .onScrollVisibilityChange { _ in
      timer.upstream.connect().cancel()
    }
    .onReceive(timer) { _ in
      withAnimation(.easeInOut(duration: 0.5)) {
        if let current = currentTab,
          let index = exploreItems.firstIndex(where: { $0.id == current })
        {
          let nextIndex = (index + 1) % max(exploreItems.count, 1)
          currentTab = exploreItems.isEmpty ? "0" : exploreItems[nextIndex].id
        } else {
          currentTab = exploreItems.isEmpty ? "0" : exploreItems.first?.id
        }
      }
    }
    .alert(message: $errorMessage)
  }

  private var loadingView: some View {
    HStack {
      Spacer()

      VStack(spacing: 12) {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
          .scaleEffect(1.2)

        Text("Loading explore spots...")
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.7))
      }

      Spacer()
    }
    .frame(height: 200)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.08))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    )
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.vertical, 10)
  }

  private var noResultsView: some View {
    HStack {
      Spacer()

      VStack(spacing: 16) {
        Image(systemName: "mountain.2")
          .font(.system(size: 40))
          .foregroundColor(.white.opacity(0.5))

        Text("No explore items found")
          .font(.headline)
          .foregroundColor(.white.opacity(0.8))

        Text("Discover climbing spots around you")
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.6))
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
      .frame(height: 200)

      Spacer()
    }
    .frame(height: 200)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.08))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    )
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .padding(.vertical, 10)
  }

  private func fetchExploreData() async {
    isLoading = true
    defer { isLoading = false }

    // TODO: use user's current location
    let query = Operations.get_sol_api_sol_Map_sol_explore.Input.Query()

    exploreItems =
      await exploreCacheClient.call(
        query, authViewModel.getAuthData(),
        {
          errorMessage = $0
        }) ?? []
  }
}

struct ExploreItemCard: View {
  let item: ExploreDto
  let geometry: GeometryProxy

  var defaultImage: some View {
    PlaceholderImage(backgroundColor: Color.gray, iconColor: Color.white)
      .frame(width: geometry.size.width, height: geometry.size.height)
  }

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      // Background image with overlay
      ZStack {
        if let photoUrl = item.photo?.url {
          AsyncImage(url: URL(string: photoUrl)) { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
            case .failure:
              defaultImage
            default:
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.newTextColor))
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
          }
        } else {
          defaultImage
        }

        // Gradient overlay
        LinearGradient(
          gradient: Gradient(colors: [
            Color.black.opacity(0.95),
            Color.black.opacity(0.6),
            Color.black.opacity(0.3),
          ]),
          startPoint: .bottom,
          endPoint: .top
        )
      }

      // Content overlay
      VStack(alignment: .leading, spacing: 0) {

        Spacer()

        Text(item.cragName ?? "Unknown Crag")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(.white)
          .lineLimit(1)
          .padding(.horizontal, 16)

        VStack(alignment: .leading, spacing: 6) {
          if let locationName = item.locationName, !locationName.isEmpty {
            Text(locationName)
              .font(.subheadline)
              .foregroundColor(.white.opacity(0.9))
              .lineLimit(2)
              .padding(.top, 4)
          }

          HStack(spacing: 12) {

            HStack(spacing: 6) {
              Image(systemName: "building.columns")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
              Text("\(item.sectorsCount ?? 0)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 6) {
              Image(systemName: "figure.climbing")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
              Text("\(item.routesCount ?? 0)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 6) {
              Image(systemName: "checkmark.circle")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
              Text("\(item.routesCount ?? 0)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            }

          }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .padding(.top, 4)
      }
    }
    .frame(width: geometry.size.width, height: geometry.size.height)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .scrollTransition { content, phase in
      content
        .opacity(phase.isIdentity ? 1 : 0.5)
        .scaleEffect(phase.isIdentity ? 1 : 0.95)
        .blur(radius: phase.isIdentity ? 0 : 5)
    }
  }
}

#Preview {
  AuthInjectionMock {
    ExploreView()
  }
}
