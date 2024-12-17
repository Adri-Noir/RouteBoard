//
//  GeneralSearchView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI
import Combine

public struct GeneralSearchView: View {
    @State private var searchText: String = ""
    @State private var debouncedSearchText: String = ""
    
    public var body: some View {
        ApplyBackgroundColor {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Capsule()
                        .fill(Color.backgroundGray)
                        .frame(width: 40, height: 10)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    TextField("", text: $searchText, prompt: Text("Search for a route").foregroundColor(.gray))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 15)
                        .background(Color.backgroundGray)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onChange(of: searchText) { value in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                debouncedSearchText = value
                            }
                        }
                        
                    
                    SearchResultView(searchText: $debouncedSearchText)
                    
                    Spacer()
                }
            }
            .padding(10)
        }
    }
}
