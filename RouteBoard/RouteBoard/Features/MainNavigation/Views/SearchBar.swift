// Created with <3 on 23.02.2025.

import Combine
import SwiftUI

struct SearchBar: View {
  @Binding var searchText: String
  @Binding var isSearching: Bool

  @FocusState var isSearchFocused: Bool

  @State private var internalSearchText: String = ""
  @State private var searchTextPublisher = PassthroughSubject<String, Never>()

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
      .padding()
      .focused($isSearchFocused)
      .background(Color.clear)
      .foregroundColor(Color.newTextColor)
      .autocorrectionDisabled()
      .autocapitalization(.none)
      .onChange(of: internalSearchText, searchTextChanged)
      .onChange(of: isSearchFocused) {
        withAnimation {
          if searchText.isEmpty {
            isSearching = isSearchFocused
          }
        }
      }
      .onReceive(
        searchTextPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
      ) { newSearchText in
        searchText = newSearchText
      }

      if isSearchFocused {
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
    .padding(.horizontal, 20)
    .onChange(of: searchText) {
      internalSearchText = searchText
    }
    .task {
      if !searchText.isEmpty {
        isSearching = true
        isSearchFocused = true
      }
    }
  }
}
