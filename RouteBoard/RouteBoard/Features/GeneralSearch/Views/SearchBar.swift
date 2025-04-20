// Created with <3 on 23.02.2025.

import Combine
import SwiftUI

enum SearchBarStyle {
  case normal
  case compact
}

struct SearchBar: View {
  @Binding var searchText: String
  var style: SearchBarStyle = .normal

  @FocusState var isSearchFocused: Bool
  @State private var internalSearchText: String = ""
  @State private var searchTextPublisher = PassthroughSubject<String, Never>()

  @EnvironmentObject var navigationManager: NavigationManager

  func searchTextChanged(_ oldSearchText: String, _ newSearchText: String) {
    searchTextPublisher.send(newSearchText)
  }

  var body: some View {
    HStack(spacing: 2) {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
        .padding(.leading)

      TextField(
        "", text: $internalSearchText, prompt: Text("Search...").foregroundColor(.gray)
      )
      .padding(style == .compact ? 12 : 16)
      .font(.body)
      .focused($isSearchFocused)
      .background(Color.clear)
      .foregroundColor(Color.newTextColor)
      .autocorrectionDisabled()
      .autocapitalization(.none)
      .onChange(of: internalSearchText, searchTextChanged)
      .onReceive(
        searchTextPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
      ) { newSearchText in
        searchText = newSearchText
      }

      if !searchText.isEmpty {
        Button(action: {
          searchText = ""
          isSearchFocused = false
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
        .padding(.trailing)
        .transition(.move(edge: .trailing).animation(.easeIn.delay(2)))
      }
    }
    .background(Color.white)
    .cornerRadius(.infinity)
    .shadow(
      color: Color.white.opacity(0.5), radius: 50, x: 0,
      y: 0
    )
    .padding(.horizontal, ThemeExtension.horizontalPadding)
    .onChange(of: searchText) {
      internalSearchText = searchText
    }
    .onChange(of: isSearchFocused) {
      if style == .normal && isSearchFocused {
        navigationManager.pushView(.generalSearch)
      }
    }
    .task {
      if style == .compact {
        isSearchFocused = true
      }
    }
  }
}
