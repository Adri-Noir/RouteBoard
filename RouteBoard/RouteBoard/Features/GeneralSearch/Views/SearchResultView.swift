//
//  SearchResultView.swift
//  RouteBoard
//
//  Created with <3 on 01.11.2024..
//

import GeneratedClient
import SwiftUI

public struct SearchResultView: View {
  @Binding public var searchText: String

  @State private var results: [GetSearchResults] = []
  @State private var isLoading: Bool = false
  @State private var errorMessage: String? = nil
  @EnvironmentObject private var authViewModel: AuthViewModel

  private var client = GetSearchResultsClient()

  init(searchText: Binding<String>) {
    _searchText = searchText
  }

  func search(value: String) async {
    results = []
    isLoading = true
    // try? await Task.sleep(nanoseconds: 1_000_000_000)
    let searchResults = await client.call(
      GetSearchResultsInput(query: value), authViewModel.getAuthData(), { errorMessage = $0 })

    withAnimation {
      results = searchResults
      isLoading = false
    }
  }

  @ViewBuilder
  private var resultsContent: some View {
    if results.isEmpty && !searchText.isEmpty && !isLoading {
      NoSearchResultsView()
    } else {
      LazyVStack(alignment: .leading, spacing: 20) {
        ForEach($results, id: \.id) { result in
          ResultTypeLinkPicker(result: result) {
            SingleResultView(result: result)
          }
        }
      }
      .padding(.horizontal, 20)
    }
  }

  public var body: some View {
    VStack(alignment: .leading) {
      if isLoading && results.isEmpty {
        LoadingSearchResultsView()
      } else {
        resultsContent
      }
    }
    .onChange(of: searchText) {
      Task(priority: .userInitiated) {
        await search(value: searchText)
      }
    }
    .alert(message: $errorMessage)
    .onDisappear {
      client.cancel()
    }
  }
}
