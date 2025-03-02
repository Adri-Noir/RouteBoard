// Created with <3 on 23.02.2025.

import GeneratedClient
import SwiftUI

struct RecentlyViewedView: View {
  @EnvironmentObject private var authViewModel: AuthViewModel

  @State private var isExpanded = false
  @State private var searchHistory: [SearchHistory] = []
  @State private var isLoading = false

  private let searchHistoryClient = SearchHistoryClient()

  var numberOfItems: Int {
    isExpanded ? min(searchHistory.count, 6) : min(searchHistory.count, 2)
  }

  var body: some View {
    VStack(alignment: .leading) {
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

      if isLoading && searchHistory.isEmpty {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
          .frame(maxWidth: .infinity, minHeight: 100)
          .background(Color.white.opacity(0.1))
          .cornerRadius(10)
      } else if searchHistory.isEmpty {
        Text("No recently viewed items")
          .foregroundColor(.white.opacity(0.7))
          .frame(maxWidth: .infinity, minHeight: 100)
          .background(Color.white.opacity(0.1))
          .cornerRadius(10)
      } else {
        LazyVStack(spacing: 0) {
          ForEach(Array(searchHistory.prefix(numberOfItems).enumerated()), id: \.element.id) {
            index, item in
            VStack(spacing: 0) {
              historyItemWithNavigation(for: item)

              if index < numberOfItems - 1 {
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
    }
    .padding(.horizontal, 20)
    .task {
      await fetchSearchHistory()
    }
  }

  private func fetchSearchHistory() async {
    isLoading = true

    let history = await searchHistoryClient.call((), authViewModel.getAuthData())
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
      Image("TestingSamples/limski/pikachu")  // Placeholder image
        .resizable()
        .frame(width: 50, height: 50)
        .cornerRadius(10)

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
      Image("TestingSamples/limski/pikachu")  // Placeholder image
        .resizable()
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
          Text("\(routesCount) routes")
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
      Image("TestingSamples/limski/pikachu")  // Placeholder image
        .resizable()
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
          Text("\(sectorsCount) sectors, \(routesCount) routes")
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
