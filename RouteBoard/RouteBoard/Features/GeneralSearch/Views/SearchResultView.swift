//
//  SearchResultView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI
import Combine
import OpenAPIRuntime
import OpenAPIURLSession
import GeneratedClient


struct SearchResultView: View {
    @Binding var searchText: String
    @State var results: [GetSearchResults] = []
    @State var isLoading: Bool = false
    private var client = GetSearchResultsClient()

    init(searchText: Binding<String>) {
        _searchText = searchText
    }

    func search(value: String) async {
        isLoading = true
        // try? await Task.sleep(nanoseconds: 1_000_000_000)
        results = await client.search(value: value)
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
                        NavigationLink(destination: SectorView()) {
                            SingleResultView(result: result)
                        }
                    }
                    .listStyle(.plain)

                }
            }
        }
        .onChange(of: searchText) {
            Task {
                await search(value: searchText)
            }
        }
    }
}
