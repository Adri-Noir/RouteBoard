//
//  SearchResultView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI

struct SearchResultView: View {
    @Binding var searchText: String
    
    // @State var searchResults: [SearchResult] = []
    
    var body: some View {
        Text("Search results for: \(searchText)")
            .foregroundStyle(.black)
    }
}
