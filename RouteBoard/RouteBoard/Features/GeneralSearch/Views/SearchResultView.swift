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

  @State private var results: [SearchResultDto] = []
  @State private var isLoading: Bool = false
  @State private var errorMessage: String? = nil
  @EnvironmentObject private var authViewModel: AuthViewModel

  private var client = GetSearchResultsClient()

  init(searchText: Binding<String>) {
    _searchText = searchText
  }

  func search(value: String) async {
    if value.count < 3 {
      return
    }

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
      LazyVStack(alignment: .leading, spacing: 12) {
        ForEach(results, id: \.id) { item in
          ResultTypeLinkPicker(result: item) {
            SingleResultView(result: item)
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
      Task {
        await search(value: searchText)
      }
    }
    .alert(message: $errorMessage)
  }
}

struct NoSearchResultsView: View {
  var body: some View {
    VStack {
      Spacer()
      Image(systemName: "magnifyingglass.circle")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundColor(.white)
      Text("No Search Results")
        .font(.headline)
        .foregroundColor(.white)
        .padding(.top)
      Text("Try searching for a different crag, sector, route or user.")
        .font(.subheadline)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .padding(.top, 2)
        .padding(.horizontal, 20)
      Spacer()
    }
    .padding()
  }
}
