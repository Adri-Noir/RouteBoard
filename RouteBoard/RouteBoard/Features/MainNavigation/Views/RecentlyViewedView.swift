// Created with <3 on 23.02.2025.

import GeneratedClient
import SwiftUI

struct RecentlyViewedView: View {
  @EnvironmentObject private var authViewModel: AuthViewModel

  @State private var isExpanded = false
  @State private var searchHistory: [SearchHistory] = []
  @State private var isLoading = false
  @State private var errorMessage: String? = nil

  private let searchHistoryClient = SearchHistoryClient()

  var numberOfItems: Int {
    isExpanded ? min(searchHistory.count, 6) : min(searchHistory.count, 2)
  }

  var body: some View {
    VStack(alignment: .leading) {
      headerView
      contentView
    }
    .padding(.horizontal, 20)
    .task {
      await fetchSearchHistory()
    }
    .alert(message: $errorMessage)
  }

  private var headerView: some View {
    HStack {
      Image(systemName: "clock")
        .foregroundColor(Color.white)

      Text("Recently Viewed")
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(Color.white)

      Spacer()

      Button(action: {
        withAnimation {
          isExpanded.toggle()
        }
      }) {
        Text(isExpanded ? "Show Less" : "Show More")
          .font(.caption2)
          .foregroundColor(.white)
          .cornerRadius(10)
      }
    }
  }

  private var contentView: some View {
    Group {
      if isLoading && searchHistory.isEmpty {
        loadingView
      } else if searchHistory.isEmpty {
        emptyStateView
      } else {
        historyListView
      }
    }
  }

  private var loadingView: some View {
    ProgressView()
      .progressViewStyle(CircularProgressViewStyle(tint: .white))
      .frame(maxWidth: .infinity, minHeight: 100)
      .background(Color.white.opacity(0.1))
      .cornerRadius(10)
  }

  private var emptyStateView: some View {
    Text("No recently viewed items")
      .foregroundColor(.white.opacity(0.7))
      .frame(maxWidth: .infinity, minHeight: 100)
      .background(Color.white.opacity(0.1))
      .cornerRadius(10)
  }

  private var historyListView: some View {
    LazyVStack(spacing: 0) {
      ForEach(isExpanded ? searchHistory : Array(searchHistory.prefix(2)), id: \.id) { item in
        VStack(spacing: 0) {
          historyItemWithNavigation(for: item)

          if item != (isExpanded ? searchHistory.last : searchHistory.prefix(2).last) {
            Divider()
              .padding(.horizontal, 10)
          }
        }
      }
    }
    .background(Color.white)
    .cornerRadius(10)
    .animation(.easeInOut(duration: 0.2), value: isExpanded)
    .shadow(color: Color.white.opacity(0.5), radius: 50, x: 0, y: 10)
  }

  private func fetchSearchHistory() async {
    isLoading = true

    let history = await searchHistoryClient.call(
      (), authViewModel.getAuthData(), { errorMessage = $0 })
    await MainActor.run {
      self.searchHistory = history
      self.isLoading = false
    }
  }

  @ViewBuilder
  private func historyItemWithNavigation(for item: SearchHistory) -> some View {
    switch item.entityType {
    case .Route:
      if let routeId = item.routeId {
        RouteLink(routeId: .constant(routeId)) {
          routeHistoryView(item)
        }
      } else {
        routeHistoryView(item)
      }
    case .Sector:
      if let sectorId = item.sectorId {
        SectorLink(sectorId: .constant(sectorId)) {
          sectorHistoryView(item)
        }
      } else {
        sectorHistoryView(item)
      }
    case .Crag:
      if let cragId = item.cragId {
        CragLink(cragId: .constant(cragId)) {
          cragHistoryView(item)
        }
      } else {
        cragHistoryView(item)
      }
    default:
      EmptyView()
    }
  }

  @ViewBuilder
  private func searchHistoryItemView(for item: SearchHistory) -> some View {
    switch item.entityType {
    case .Route:
      routeHistoryView(item)
    case .Sector:
      sectorHistoryView(item)
    case .Crag:
      cragHistoryView(item)
    default:
      EmptyView()
    }
  }

  @ViewBuilder
  private func routeHistoryView(_ item: SearchHistory) -> some View {
    HStack {
      let photoUrl = item.photo?.url
      if let photoUrl = photoUrl {
        AsyncImage(url: URL(string: photoUrl)) { phase in
          switch phase {
          case .empty:
            PlaceholderImage(backgroundColor: Color.gray, iconColor: Color.white)
              .frame(width: 50, height: 50)
              .cornerRadius(10)
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 50, height: 50)
              .clipped()
              .cornerRadius(10)
          case .failure:
            PlaceholderImage(backgroundColor: Color.gray, iconColor: Color.white)
              .frame(width: 50, height: 50)
          @unknown default:
            PlaceholderImage(backgroundColor: Color.gray, iconColor: Color.white)
              .frame(width: 50, height: 50)
          }
        }
      } else {
        PlaceholderImage(backgroundColor: Color.gray, iconColor: Color.white)
          .frame(width: 50, height: 50)
      }

      VStack(alignment: .leading) {
        HStack(spacing: 4) {
          Text(item.routeName ?? "Unknown Crag")
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(Color.newTextColor)

          Text("Route")
            .font(.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }

        Text(item.routeSectorName ?? "Unknown Sector")
          .font(.caption)
          .foregroundColor(.gray)

        if let difficulty = item.routeDifficulty {
          Text("Grade: \(authViewModel.getGradeSystem().convertGradeToString(difficulty))")
            .font(.caption)
            .foregroundColor(.gray)
        }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 10)
    .background(Color.white)
  }

  @ViewBuilder
  private func sectorHistoryView(_ item: SearchHistory) -> some View {
    HStack {
      PlaceholderImage(iconFont: .body)
        .frame(width: 50, height: 50)
        .cornerRadius(10)

      VStack(alignment: .leading) {
        HStack(spacing: 4) {
          Text(item.sectorName ?? "Unknown Sector")
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(Color.newTextColor)

          Text("Sector")
            .font(.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.green.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }

        Text(item.sectorCragName ?? "Unknown Crag")
          .font(.caption)
          .foregroundColor(.gray)

        if let routesCount = item.sectorRoutesCount {
          Text("\(routesCount) Routes")
            .font(.caption)
            .foregroundColor(.gray)
        }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 10)
    .background(Color.white)
  }

  @ViewBuilder
  private func cragHistoryView(_ item: SearchHistory) -> some View {
    HStack {
      PlaceholderImage(iconFont: .body)
        .frame(width: 50, height: 50)
        .cornerRadius(10)

      VStack(alignment: .leading) {
        HStack(spacing: 4) {
          Text(item.cragName ?? "Unknown Crag")
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(Color.newTextColor)

          Text("Crag")
            .font(.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.orange.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }

        if let sectorsCount = item.cragSectorsCount, let routesCount = item.cragRoutesCount {
          Text("\(sectorsCount) Sectors, \(routesCount) Routes")
            .font(.caption)
            .foregroundColor(.gray)
        }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 10)
    .background(Color.white)
  }
}

#Preview {
  AuthInjectionMock {
    RecentlyViewedView()
  }
}
