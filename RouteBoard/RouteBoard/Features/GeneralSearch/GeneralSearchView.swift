//
//  GeneralSearchView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import Combine
import SwiftUI

public struct GeneralSearchView: View {
  @State private var searchText: String = ""
  @State private var debouncedSearchText: String = ""
  private let searchTextPublisher = PassthroughSubject<String, Never>()

  public var body: some View {
    ApplyBackgroundColor {
      VStack(alignment: .leading, spacing: 10) {
        TextField("", text: $searchText, prompt: Text("Search for a route").foregroundColor(.gray))
          .autocorrectionDisabled()
          .autocapitalization(.none)
          .padding(.horizontal, 10)
          .padding(.vertical, 15)
          .background(Color.backgroundGray)
          .foregroundStyle(.black)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .onChange(of: searchText, initial: false) {
            searchTextPublisher.send(searchText)
          }
          .onReceive(
            searchTextPublisher
              .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
          ) { debouncedSearchText in
            self.debouncedSearchText = debouncedSearchText
          }

        SearchResultView(searchText: $debouncedSearchText)

        Spacer()
      }
      .padding(10)
    }
  }
}
