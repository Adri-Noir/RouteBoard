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
      ZStack(alignment: .top) {
        // Header
        HStack(spacing: 0) {
          // Back button
          Button(action: {
            navigationManager.pop()
          }) {
            Image(systemName: "chevron.left")
              .foregroundColor(.white)
              .background(Color.clear)
              .clipShape(Circle())
          }

          SearchBar(searchText: $searchText, style: .compact)

          Button(action: {
            // TODO: Add filter action
          }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
              .foregroundColor(.white)
          }
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
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
            SearchResultView(searchText: $searchText)
            Spacer()
          }
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
