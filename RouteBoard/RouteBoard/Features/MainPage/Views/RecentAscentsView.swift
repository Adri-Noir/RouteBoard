//
//  RecentAscentsView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI


struct RecentAscentsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent ascents")
                .font(.headline)
                .foregroundStyle(.black)
                .padding(.bottom, 10)


            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(250))], spacing: 10) {
                    ForEach(0..<10) { index in
                        NavigationLink(destination: SectorView()) {
                            RouteAscentView()
                        }
                    }
                }
                .frame(height: 250)
            }

            Spacer()
        }
    }
}
