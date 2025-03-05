// Created with <3 on 04.03.2025.

import Charts
import SwiftUI

struct RegisteredUserView: View {
  @State private var headerVisibleRatio: CGFloat = 1
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss
  @State private var selectedAscentType: AscentType = .all

  // Mock data
  private let userStats = UserStats(cragsVisited: 24, followers: 156, following: 87)
  private let climbingStats = [
    ClimbingStat(type: "Onsight", count: 42, color: .green),
    ClimbingStat(type: "Flash", count: 28, color: .blue),
    ClimbingStat(type: "Redpoint", count: 63, color: .red),
    ClimbingStat(type: "Top Rope", count: 35, color: .orange),
  ]
  private let mockPhotos = (1...6).map { _ in "climbing_photo" }
  private let mockFriends = [
    Friend(name: "Alex Honnold", image: "person.fill"),
    Friend(name: "Adam Ondra", image: "person.fill"),
    Friend(name: "Janja Garnbret", image: "person.fill"),
    Friend(name: "Chris Sharma", image: "person.fill"),
    Friend(name: "Shauna Coxsey", image: "person.fill"),
  ]

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
  }

  var navigationBarExpanded: some View {
    VStack(alignment: .center, spacing: 16) {
      Spacer()

      HStack(alignment: .center, spacing: 16) {
        Spacer()

        Image(systemName: "person.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(.white)
          .frame(width: 80, height: 80)
          .clipShape(Circle())
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

        VStack(alignment: .leading, spacing: 4) {
          Text(authViewModel.user?.username ?? "User")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)

          Text("Climber Profile")
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))
        }

        Spacer()
      }
      .padding(.horizontal, 20)

      Spacer()
    }
  }

  var navigationBarCollapsed: some View {
    HStack {
      Button(action: {
        dismiss()
      }) {
        Image(systemName: "chevron.left")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .padding(8)
          .background(Color.black.opacity(0.75))
          .clipShape(Circle())
      }

      Spacer()

      Group {

        Image(systemName: "person.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(.white)
          .frame(width: 40, height: 40)
          .clipShape(Circle())
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

        Text(authViewModel.user?.username ?? "User")
          .fontWeight(.bold)
          .foregroundColor(.white)
      }
      .opacity(1 - headerVisibleRatio)

      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 5)
    .background(
      Color.newPrimaryColor.ignoresSafeArea().background(.ultraThinMaterial).opacity(
        1 - headerVisibleRatio)
    )
    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
    .animation(.easeInOut(duration: 0.2), value: headerVisibleRatio)
    .padding(.top, safeAreaInsets.top)
  }

  var userStatsView: some View {
    HStack(spacing: 30) {
      StatItem(value: "\(userStats.cragsVisited)", label: "Crags")
      Divider().frame(height: 40)
      StatItem(value: "\(userStats.followers)", label: "Followers")
      Divider().frame(height: 40)
      StatItem(value: "\(userStats.following)", label: "Following")
    }
    .padding(.vertical)
    .padding(.horizontal, 30)
    .background(Color.white)
    .cornerRadius(12)
  }

  var climbingStatsTableView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Climbing Stats")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      VStack(spacing: 0) {
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
        .padding(.horizontal, 12)
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
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.7))

            if index < climbingStats.count - 1 {
              Divider()
                .padding(.horizontal, 12)
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
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.9))
      }
      .cornerRadius(8)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }

  var climbingStatsGraphView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Performance Graph")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      Chart {
        ForEach(climbingStats) { stat in
          BarMark(
            x: .value("Type", stat.type),
            y: .value("Count", stat.count)
          )
          .foregroundStyle(stat.color)
        }
      }
      .frame(height: 200)
      .chartYScale(domain: 0...(climbingStats.map { $0.count }.max() ?? 0) + 10)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }

  var ascentTypeSelectorView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Filter by Ascent Type")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(AscentType.allCases, id: \.self) { type in
            Button(action: {
              withAnimation {
                selectedAscentType = type
              }
            }) {
              Text(type.rawValue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                  selectedAscentType == type ? Color.newPrimaryColor : Color.newBackgroundGray
                )
                .foregroundColor(selectedAscentType == type ? .white : Color.newTextColor)
                .cornerRadius(20)
            }
          }
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }

  var photosGridView: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Photos")
          .font(.headline)
          .foregroundColor(Color.newTextColor)

        Spacer()

        Button(action: {}) {
          Text("See All")
            .font(.subheadline)
            .foregroundColor(Color.newPrimaryColor)
        }
      }

      LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8
      ) {
        ForEach(0..<mockPhotos.count, id: \.self) { index in
          Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 75)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.newTextColor)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }

  var friendsListView: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Friends")
          .font(.headline)
          .foregroundColor(Color.newTextColor)

        Spacer()

        Button(action: {}) {
          Text("See All")
            .font(.subheadline)
            .foregroundColor(Color.newPrimaryColor)
        }
      }

      ForEach(mockFriends) { friend in
        HStack(spacing: 12) {
          Image(systemName: friend.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
            .padding(4)
            .background(Color.gray.opacity(0.3))
            .clipShape(Circle())

          Text(friend.name)
            .foregroundColor(Color.newTextColor)

          Spacer()

          Button(action: {}) {
            Text("Follow")
              .font(.caption)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(Color.newPrimaryColor)
              .foregroundColor(.white)
              .cornerRadius(12)
          }
        }
        .padding(.vertical, 4)
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
  }

  var body: some View {
    ScrollViewWithStickyHeader(
      header: {
        navigationBarExpanded
      },
      headerOverlay: {
        navigationBarCollapsed
      }, headerHeight: 200,
      onScroll: { _, headerVisibleRatio in
        self.headerVisibleRatio = headerVisibleRatio
      }
    ) {
      VStack(spacing: 20) {
        userStatsView
        ascentTypeSelectorView
        climbingStatsTableView
        climbingStatsGraphView
        photosGridView
        friendsListView
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 30)
    }
    .background(Color.newPrimaryColor)
    .navigationBarBackButtonHidden()
  }
}

// MARK: - Supporting Models
struct UserStats {
  let cragsVisited: Int
  let followers: Int
  let following: Int
}

struct ClimbingStat: Identifiable {
  let id = UUID()
  let type: String
  let count: Int
  let color: Color
}

struct Friend: Identifiable {
  let id = UUID()
  let name: String
  let image: String
}

enum AscentType: String, CaseIterable {
  case all = "All"
  case boulder = "Boulder"
  case sport = "Sport"
  case trad = "Trad"
  case aid = "Aid"
}

// MARK: - Supporting Views
struct StatItem: View {
  let value: String
  let label: String

  var body: some View {
    VStack(alignment: .center, spacing: 4) {
      Text(value)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(Color.newTextColor)

      Text(label)
        .font(.caption)
        .foregroundColor(Color.newTextColor.opacity(0.8))
    }
  }
}

#Preview {
  AuthInjectionMock {
    RegisteredUserView()
  }
}
