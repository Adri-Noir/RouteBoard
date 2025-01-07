//
//  SearchResultView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import Combine
import GeneratedClient
import OpenAPIRuntime
import OpenAPIURLSession
import SwiftUI

struct SearchResultView: View {
  @Binding public var searchText: String

  @State private var results: [GetSearchResults] = []
  @State private var isLoading: Bool = false

  @EnvironmentObject private var authViewModel: AuthViewModel

  private var client = GetSearchResultsClient()

  init(searchText: Binding<String>) {
    _searchText = searchText
  }

  func search(value: String) async {
    isLoading = true
    // try? await Task.sleep(nanoseconds: 1_000_000_000)
    results = await client.call(
      GetSearchResultsInput(query: value), authViewModel.getAuthData())
    isLoading = false
  }

  var body: some View {
    VStack(alignment: .leading) {
      if isLoading {
        LoadingSearchResultsView()
      } else {
        if results.isEmpty {
          NoSearchResultsView()
        } else {
          List($results, id: \.self.id) { result in
            ResultTypeLinkPicker(result: result) {
              SingleResultView(result: result)
            }
          }
          .listStyle(.plain)

        }
      }
    }
    .onChange(of: searchText) {
      Task(priority: .userInitiated) {
        await search(value: searchText)
      }
    }
  }
}
