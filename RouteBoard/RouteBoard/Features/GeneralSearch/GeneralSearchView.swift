//
//  GeneralSearchView.swift
//  RouteBoard
//
//  Created with <3 on 01.11.2024..
//

import Combine
import SwiftUI

public struct GeneralSearchView: View {
  @State private var searchText: String = ""

  @EnvironmentObject var navigationManager: NavigationManager

  public var body: some View {
    ApplyBackgroundColor(backgroundColor: .newPrimaryColor) {
      ScrollView {
        VStack(alignment: .leading, spacing: 30) {
          HStack {
            Button(action: {
              navigationManager.pop()
            }) {
              Image(systemName: "chevron.left")
                .foregroundColor(.white)
            }

            Text("Search")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(.white)

            Spacer()
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
          .padding(.bottom, 12)

          SearchBar(searchText: $searchText, shouldFocusOnShow: true)

          SearchResultView(searchText: $searchText)

          Spacer()
        }
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}

#Preview {
  Navigator { _ in
    AuthInjectionMock {
      GeneralSearchView()
    }
  }
}
