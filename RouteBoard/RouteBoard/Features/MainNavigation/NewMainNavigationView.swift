// Created with <3 on 20.02.2025.

import SwiftUI

struct NewMainNavigationView: View {
  @EnvironmentObject var authViewModel: AuthViewModel

  @State private var searchText = ""
  @State private var showProfileView = false

  var body: some View {
    Navigator { manager in
      ApplyBackgroundColor(backgroundColor: Color.newPrimaryColor) {
        ScrollView {
          VStack(alignment: .leading, spacing: 30) {
            UserHelloView(showProfileView: $showProfileView)
            SearchBar(searchText: $searchText, style: .normal)
            RecentlyViewedView()
            UserRecentAscentsView()
            ExploreView()

            Spacer()
          }
        }
      }
      .accentColor(Color.newPrimaryColor)
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
