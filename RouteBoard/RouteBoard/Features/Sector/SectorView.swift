//
//  SectorView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 02.07.2024..
//

import SwiftUI

struct SectorView: View {
    @State private var show = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    ImageCarouselView(imagesNames:["TestingSamples/r3", "TestingSamples/flok"]);
                    
                    // TODO: this has to be written better
                    VStack(alignment: .center, spacing: 0) {
                        HStack {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.up")
                                Text("15 Routes")
                            }
                            ExtendedDivider(direction: .vertical)
                                .frame(height: 75)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            HStack(spacing: 10) {
                                Image(systemName: "hands.clap")
                                Text("20 Ascents")
                            }
                        }
                        ExtendedDivider()
                        HStack {
                            HStack(spacing: 0) {
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                
                            }
                            ExtendedDivider(direction: .vertical)
                                .frame(height: 75)
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing:20))
                            HStack(spacing: 10) {
                                Image(systemName: "grid.circle")
                                VStack {
                                    Text("Grades:")
                                    Text("4c - 8a")
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity,
                       alignment: .topLeading)
                
                Button {
                    self.show = true
                } label: {
                    Image(systemName: "eye")
                        .font(.title.weight(.semibold))
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding()
                .fullScreenCover(isPresented: self.$show) {
                    RouteFinderView()
                }
            }
            .navigationTitle("F - Stari grad")
        }
    }
}

#Preview {
    SectorView()
}
