// Created with <3 on 04.03.2025.

import Charts
import GeneratedClient
import SwiftUI

struct RegisteredUserView: View {
  @State private var headerVisibleRatio: CGFloat = 1
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss

  @State private var userProfile: UserProfile?
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var selectedAscentType: Components.Schemas.RouteType?

  private let getUserProfileClient = GetUserProfileClient()

  private var safeAreaInsets: UIEdgeInsets {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else { return .zero }
    return window.safeAreaInsets
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
      if isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding(.top, 50)
      } else if let errorMessage = errorMessage {
        VStack {
          Text("Error loading profile")
            .font(.headline)
            .foregroundColor(.red)

          Text(errorMessage)
            .font(.subheadline)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding()
        }
        .padding(.top, 50)
      } else {
        VStack(spacing: 20) {
          userStatsView
          ascentTypeSelectorView
          climbingStatsTableView
          climbingStatsGraphView
          climbingGradesGraphView
          photosGridView
          friendsListView
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
      }
    }
    .background(Color.newPrimaryColor)
    .navigationBarBackButtonHidden()
    .onAppear {
      if let userId = authViewModel.user?.id {
        Task {
          await fetchUserProfile(userId: userId, authData: authViewModel.getAuthData())
        }
      }
    }
    .onDisappear {
      getUserProfileClient.cancel()
    }
  }

  private func fetchUserProfile(userId: String, authData: AuthData) async {
    await MainActor.run {
      isLoading = true
      errorMessage = nil
    }

    let profileInput = UserProfileInput(profileUserId: userId)

    let profile = await getUserProfileClient.call(profileInput, authData) { errorMessage in
      Task { @MainActor in
        self.errorMessage = errorMessage
        self.isLoading = false
      }
    }

    await MainActor.run {
      self.userProfile = profile
      self.isLoading = false
    }
  }

  // MARK: - Calculated Properties

  private var climbingStats: [ClimbingStat] {
    guard let routeTypeAscentCount = userProfile?.routeTypeAscentCount,
      !routeTypeAscentCount.isEmpty
    else {
      return []
    }

    guard let routeTypeAscentCount = userProfile?.routeTypeAscentCount,
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
            if let ascentType = ascentCount.ascentType?.rawValue, let count = ascentCount.count,
              count > 0
            {
              let color: Color
              switch ascentType {
              case "Onsight": color = .green
              case "Flash": color = .blue
              case "Redpoint": color = .red
              case "Aid": color = .orange
              default: color = .gray
              }
              stats.append(ClimbingStat(type: ascentType, count: Int(count), color: color))
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
            if let ascentType = ascentCount.ascentType?.rawValue, let count = ascentCount.count {
              ascentCounts[ascentType] = (ascentCounts[ascentType] ?? 0) + Int(count)
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

  private var climbingGradesStats: [GradeStat] {
    // Return cached results if available
    guard let climbingGradeAscentCount = userProfile?.climbingGradeAscentCount,
      !climbingGradeAscentCount.isEmpty
    else {
      return []
    }

    var stats: [GradeStat] = []

    // Filter by selected ascent type if not "All"
    let filteredGradeData: [Components.Schemas.ClimbingGradeAscentCountDto]
    if let selectedType = self.selectedAscentType {
      filteredGradeData = climbingGradeAscentCount.filter {
        $0.routeType?.rawValue == selectedType.rawValue
      }

      // If no data for the selected route type, return empty array
      if filteredGradeData.isEmpty {
        return []
      }
    } else {
      filteredGradeData = climbingGradeAscentCount
    }

    // Create a dictionary to aggregate counts for the same grade
    var gradeCounts: [String: (count: Int, color: Color)] = [:]

    // Process the climbing grades data
    for gradeData in filteredGradeData {
      if let gradeCountArray = gradeData.gradeCount {
        for gradeCount in gradeCountArray {
          if let grade = gradeCount.climbingGrade, let count = gradeCount.count, count > 0 {
            // Format the grade label for display
            let displayLabel = authViewModel.getGradeSystem().convertGradeToString(grade)

            // Determine color based on grade difficulty
            let color: Color
            if displayLabel.contains("9") {
              color = .red
            } else if displayLabel.contains("8") {
              color = .orange
            } else if displayLabel.contains("7") {
              color = .yellow
            } else if displayLabel.contains("6") {
              color = .green
            } else {
              color = .blue
            }

            // Add or update the count in our dictionary
            if let existing = gradeCounts[displayLabel] {
              gradeCounts[displayLabel] = (count: existing.count + Int(count), color: color)
            } else {
              gradeCounts[displayLabel] = (count: Int(count), color: color)
            }
          }
        }
      }
    }

    for (grade, data) in gradeCounts {
      stats.append(GradeStat(grade: grade, count: data.count, color: data.color))
    }

    let sortedStats = stats.sorted { (a, b) -> Bool in
      let aIndex = authViewModel.getGradeSystem().climbingGrades.firstIndex(of: a.grade) ?? Int.max
      let bIndex = authViewModel.getGradeSystem().climbingGrades.firstIndex(of: b.grade) ?? Int.max
      return aIndex < bIndex
    }

    return sortedStats
  }

  // MARK: - View Components

  var navigationBarExpanded: some View {
    VStack(alignment: .center, spacing: 16) {
      Spacer()

      HStack(alignment: .center, spacing: 16) {
        Spacer()

        if let profilePhotoUrl = userProfile?.profilePhotoUrl, !profilePhotoUrl.isEmpty {
          AsyncImage(url: URL(string: profilePhotoUrl)) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          } placeholder: {
            Image(systemName: "person.circle.fill")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(.white)
          }
          .frame(width: 80, height: 80)
          .clipShape(Circle())
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        } else {
          Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }

        VStack(alignment: .leading, spacing: 4) {
          Text(userProfile?.username ?? authViewModel.user?.username ?? "User")
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
        if let profilePhotoUrl = userProfile?.profilePhotoUrl, !profilePhotoUrl.isEmpty {
          AsyncImage(url: URL(string: profilePhotoUrl)) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          } placeholder: {
            Image(systemName: "person.circle.fill")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(.white)
          }
          .frame(width: 40, height: 40)
          .clipShape(Circle())
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        } else {
          Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }

        Text(userProfile?.username ?? authViewModel.user?.username ?? "User")
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
      StatItem(value: "\(userProfile?.cragsVisited ?? 0)", label: "Crags")
      Divider().frame(height: 40)
      StatItem(value: "0", label: "Followers")  // API doesn't provide followers count yet
      Divider().frame(height: 40)
      StatItem(value: "0", label: "Following")  // API doesn't provide following count yet
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

        if climbingStats.isEmpty {
          Text("No climbing stats available")
            .foregroundColor(Color.newTextColor.opacity(0.7))
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
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

      if climbingStats.isEmpty {
        Text("No data available for graph")
          .foregroundColor(Color.newTextColor.opacity(0.7))
          .padding()
          .frame(maxWidth: .infinity, alignment: .center)
          .frame(height: 200)
      } else {
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
          // Add "All" button
          Button(action: {
            withAnimation {
              selectedAscentType = nil
            }
          }) {
            Text("All")
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
              .background(
                selectedAscentType == nil
                  ? Color.newPrimaryColor : Color.newBackgroundGray
              )
              .foregroundColor(selectedAscentType == nil ? .white : Color.newTextColor)
              .cornerRadius(20)
          }

          // Add other route type buttons
          ForEach(Components.Schemas.RouteType.allCases, id: \.self) { type in
            Button(action: {
              withAnimation {
                selectedAscentType = type
              }
            }) {
              Text(type.rawValue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                  selectedAscentType == type
                    ? Color.newPrimaryColor : Color.newBackgroundGray
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

  var climbingGradesGraphView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Climbing Grades Distribution")
        .font(.headline)
        .foregroundColor(Color.newTextColor)

      if let selectedType = selectedAscentType {
        Text("Filtered by: \(selectedType.rawValue)")
          .font(.subheadline)
          .foregroundColor(Color.newTextColor.opacity(0.7))
      }

      if climbingGradesStats.isEmpty {
        Text(
          "No grade data available\(selectedAscentType != nil ? " for \(selectedAscentType!.rawValue)" : "")"
        )
        .foregroundColor(Color.newTextColor.opacity(0.7))
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 200)
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          Chart {
            ForEach(climbingGradesStats) { stat in
              BarMark(
                x: .value("Grade", stat.grade),
                y: .value("Count", stat.count)
              )
              .foregroundStyle(stat.color)
              .annotation(position: .top) {
                Text("\(stat.count)")
                  .font(.caption2)
                  .foregroundColor(Color.newTextColor)
              }
            }
          }
          .frame(height: 250)
          .frame(
            width: max(CGFloat(climbingGradesStats.count * 40), UIScreen.main.bounds.width - 80)
          )
          .chartYScale(domain: 0...(climbingGradesStats.map { $0.count }.max() ?? 0) + 5)
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

      if let photos = userProfile?.photos, !photos.isEmpty {
        LazyVGrid(
          columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8
        ) {
          ForEach(photos, id: \.id) { photo in
            if let photoUrl = photo.url, !photoUrl.isEmpty {
              AsyncImage(url: URL(string: photoUrl)) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
              } placeholder: {
                Image(systemName: "photo")
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .foregroundColor(Color.newTextColor)
              }
              .frame(height: 75)
              .frame(maxWidth: .infinity)
              .background(Color.gray.opacity(0.3))
              .cornerRadius(8)
            } else {
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
      } else {
        Text("No photos available")
          .foregroundColor(Color.newTextColor.opacity(0.7))
          .padding()
          .frame(maxWidth: .infinity, alignment: .center)
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

      // API doesn't provide friends yet, so we'll keep the mock data for now
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

struct GradeStat: Identifiable {
  let id = UUID()
  let grade: String
  let count: Int
  let color: Color
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

// Mock data for friends (API doesn't provide this yet)
private let mockFriends = [
  Friend(name: "Alex Honnold", image: "person.fill"),
  Friend(name: "Adam Ondra", image: "person.fill"),
  Friend(name: "Janja Garnbret", image: "person.fill"),
  Friend(name: "Chris Sharma", image: "person.fill"),
  Friend(name: "Shauna Coxsey", image: "person.fill"),
]

#Preview {
  AuthInjectionMock {
    RegisteredUserView()
  }
}
