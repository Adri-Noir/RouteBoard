// Created with <3 on 16.03.2025.

import Charts
import GeneratedClient
import SwiftUI

// MARK: - Main View
struct UserView: View {
  let userId: String

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
        ProfileHeaderExpandedView(userProfile: userProfile, username: userProfile?.username)
      },
      headerOverlay: {
        ProfileHeaderCollapsedView(
          userProfile: userProfile,
          username: userProfile?.username,
          headerVisibleRatio: headerVisibleRatio
        )
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
        ErrorView(errorMessage: errorMessage)
      } else {
        VStack(spacing: 20) {
          UserStatsView(cragsVisited: Int(userProfile?.cragsVisited ?? 0))
          AscentTypeSelectorView(
            selectedAscentType: $selectedAscentType
          )
          ClimbingStatsTableView(
            climbingStats: climbingStats,
            selectedAscentType: selectedAscentType
          )
          ClimbingStatsGraphView(
            climbingStats: climbingStats,
            selectedAscentType: selectedAscentType
          )
          ClimbingGradesGraphView(
            climbingGradesStats: climbingGradesStats,
            selectedAscentType: selectedAscentType
          )
          PhotosGridView(photos: userProfile?.photos)
          FriendsListView()
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
        .padding(.bottom, 30)
      }
    }
    .background(Color.newPrimaryColor)
    .navigationBarBackButtonHidden()
    .task {
      await fetchUserProfile(userId: userId)
    }
  }

  private func fetchUserProfile(userId: String) async {
    await MainActor.run {
      isLoading = true
      errorMessage = nil
    }

    let profileInput = UserProfileInput(profileUserId: userId)

    let profile = await getUserProfileClient.call(profileInput, authViewModel.getAuthData()) {
      errorMessage in
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
    return AscentTypeStatistics.calculateAscentStats(
      routeTypeAscentCount: userProfile?.routeTypeAscentCount,
      selectedAscentType: selectedAscentType
    )
  }

  private var climbingGradesStats: [GradeStat] {
    return ClimbingGradeStatistics.calculateGradeStats(
      climbingGradeAscentCount: userProfile?.climbingGradeAscentCount,
      selectedAscentType: selectedAscentType,
      gradeSystem: authViewModel.getGradeSystem()
    )
  }
}

#Preview {
  AuthInjectionMock {
    UserView(userId: "preview-user-id")
  }
}
