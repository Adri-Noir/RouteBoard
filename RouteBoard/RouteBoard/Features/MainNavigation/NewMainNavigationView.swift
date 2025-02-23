// Created with <3 on 20.02.2025.

import SwiftUI

struct NewMainNavigationView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var searchText = ""
  @State private var isSearching = false
  @State private var rotation: Double = 0

  var insets: UIEdgeInsets {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = scene.windows.first
    else {
      return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    return window.safeAreaInsets
  }

  var body: some View {
    NavigationStack {
      ApplyBackgroundColor(backgroundColor: Color.newPrimaryColor) {
        ScrollView {
          VStack(alignment: .leading, spacing: 30) {
            if !isSearching {
              UserHelloView()
            }

            SearchBar(searchText: $searchText, isSearching: $isSearching)

            if !isSearching {
              RecentlyViewedView()
              UserRecentAscentsView()
              ExploreView()
            }

            if isSearching {
              SearchResultView(searchText: $searchText)
            }

            Spacer()
          }
        }
      }
    }
    .accentColor(Color.primaryColor)
  }
}

#Preview {
  AuthInjectionMock {
    NewMainNavigationView()
  }
}
