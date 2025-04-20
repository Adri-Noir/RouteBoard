// Created with <3 on 20.02.2025.

import SwiftUI

struct MainNavigationView: View {
  @EnvironmentObject var authViewModel: AuthViewModel

  @State private var searchText = ""
  @State private var showProfileView = false

  var body: some View {
    Navigator { manager in
      ApplyBackgroundColor(backgroundColor: Color.newPrimaryColor) {
        ZStack(alignment: .top) {
          UserHelloView(showProfileView: $showProfileView)
            .padding(.bottom, 12)
            .background(Color.newPrimaryColor.opacity(0.98).ignoresSafeArea())
            .zIndex(1)
            .overlay(
              Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.18)),
              alignment: .bottom
            )

          ScrollView {
            VStack(alignment: .leading, spacing: 30) {
              Color.clear.frame(height: 56)
              SearchBar(searchText: $searchText, style: .normal)
              RecentlyViewedView()
              UserRecentAscentsView()
              ExploreView()
              Spacer()
            }
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
      MainNavigationView()
    }
  }
}
