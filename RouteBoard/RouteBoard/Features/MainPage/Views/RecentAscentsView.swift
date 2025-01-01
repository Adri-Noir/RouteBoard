//
//  RecentAscentsView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI


struct RecentAscentsView: View {
    @State var testSectorId: String? = "d9872fa7-8859-410e-9199-08dcf8780f2f"

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent ascents")
                .font(.headline)
                .foregroundStyle(.black)
                .padding(.bottom, 10)


            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(250))], spacing: 10) {
                    ForEach(0..<10) { index in
                        SectorLink(sectorId: $testSectorId) {
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
