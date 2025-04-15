// Created with <3 on 20.02.2025.

import SwiftUI

struct NewMainNavigationView: View {
  @EnvironmentObject var authViewModel: AuthViewModel

  @State private var searchText = ""
  @State private var isSearching = false
  @State private var showProfileView = false

  var body: some View {
    Navigator { manager in
      ApplyBackgroundColor(backgroundColor: Color.newPrimaryColor) {
        ScrollView {
          VStack(alignment: .leading, spacing: 30) {
            if !isSearching {
              UserHelloView(showProfileView: $showProfileView)
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
      .accentColor(Color.primaryColor)
    }
  }
}

#Preview {
  APIClientInjection {
    AuthInjectionMock {
      NewMainNavigationView()
    }
  }
}
