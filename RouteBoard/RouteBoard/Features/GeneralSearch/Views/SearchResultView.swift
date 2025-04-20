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
  @State private var recentlyViewed: [SearchResultDto] = []
  @State private var isLoadingRecentlyViewed: Bool = false

  private var client = GetSearchResultsClient()
  private let searchHistoryClient = SearchHistoryClient()

  init(searchText: Binding<String>) {
    _searchText = searchText
  }

  func search(value: String) async {
    if value.count < 3 {
      return
    }

    results = []
    isLoading = true
    let searchResults = await client.call(
      GetSearchResultsInput(query: value), authViewModel.getAuthData(), { errorMessage = $0 })

    withAnimation {
      results = searchResults
      isLoading = false
    }
  }

  func fetchRecentlyViewed() async {
    isLoadingRecentlyViewed = true
    let history = await searchHistoryClient.call(
      (), authViewModel.getAuthData(), { errorMessage = $0 })
    Task { @MainActor in
      self.recentlyViewed = history
      self.isLoadingRecentlyViewed = false
    }
  }

  @ViewBuilder
  private var resultsHeader: some View {
    if searchText.count < 2 {
      Text("Recently Viewed")
        .font(.headline)
        .foregroundColor(.white)
        .padding(.bottom, 8)
        .padding(.leading, ThemeExtension.horizontalPadding)
    } else if !searchText.isEmpty {
      Text("Search Results")
        .font(.headline)
        .foregroundColor(.white)
        .padding(.bottom, 8)
        .padding(.leading, ThemeExtension.horizontalPadding)
    }
  }

  @ViewBuilder
  private var resultsContent: some View {
    VStack(alignment: .leading, spacing: 0) {
      resultsHeader
      if searchText.count < 2 {
        if isLoadingRecentlyViewed {
          LoadingSearchResultsView()
        } else if recentlyViewed.isEmpty {
          NoSearchResultsView()
        } else {
          LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(recentlyViewed, id: \.id) { item in
              ResultTypeLinkPicker(result: item) {
                SingleResultView(result: item)
              }
            }
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)
        }
      } else if results.isEmpty && !searchText.isEmpty && !isLoading {
        NoSearchResultsView()
      } else {
        LazyVStack(alignment: .leading, spacing: 12) {
          ForEach(results, id: \.id) { item in
            ResultTypeLinkPicker(result: item) {
              SingleResultView(result: item)
            }
          }
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      }
    }
  }

  public var body: some View {
    VStack(alignment: .leading) {
      if (isLoading && results.isEmpty) || (isLoadingRecentlyViewed && searchText.count < 2) {
        LoadingSearchResultsView()
      } else {
        resultsContent
      }
    }
    .onChange(of: searchText) {
      Task {
        if searchText.count >= 3 {
          await search(value: searchText)
        }
      }
    }
    .onAppear {
      Task {
        await fetchRecentlyViewed()
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
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      Spacer()
    }
    .padding()
  }
}
