//
//  SectorView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 02.07.2024..
//

import SwiftUI

struct SectorView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var show = false
    @State private var showRoutes = false
    
    
    @ViewBuilder
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.94, green: 0.93, blue: 0.93).ignoresSafeArea()
                
                
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ImageCarouselView(imagesNames:["TestingSamples/r3", "TestingSamples/flok"], height: 500)
                                .cornerRadius(20)
                            
                            Text("Stari grad")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .padding()
                            
                            Text("Neki kratki opis")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.black)
                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 10))
                            
                            InformationRectanglesView(handleOpenRoutesView: {
                                showRoutes = true
                            }, handleLike: {
                                print("liked sector")
                            }, ascentsGraph: {
                                Text("Ascents")
                            }, gradesGraphModel: GradesGraphModel(grades: [GradeCount(grade: "5c", count: 1), GradeCount(grade: "6c", count: 3), GradeCount(grade: "6a", count: 1)]))

                            Text("Current weather")
                                .padding(.vertical)
                                .font(.title)
                                .foregroundStyle(.black)
                            
                            Button {
                                
                            } label: {
                                Text("bla bla")
                                    .padding()
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .background(Color(red: 0.78, green: 0.62, blue: 0.52))
                            .padding(.vertical)
                            .cornerRadius(20)
                            
                            Text("Recent ascents")
                                .font(.title)
                                .foregroundStyle(.black)
                        }
                        .padding()
                    }
                    
                    Button {
                        self.show = true
                    } label: {
                        Image(systemName: "eye")
                            .font(.title.weight(.semibold))
                            .padding()
                            .background(Color(red: 0.78, green: 0.62, blue: 0.52))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding()
                    .fullScreenCover(isPresented: self.$show) {
                        RouteFinderView()
                    }
                }
                .navigationBarTitleDisplayMode(.large)
                .navigationBarHidden(true)
                .popover(isPresented: $showRoutes) {
                    RoutesListView(routes: [SimpleRoute(id: "1", name: "Apaches", grade: "6b", numberOfAscents: 1)])
                }
            }
            
        }
    }
}


#Preview {
    SectorView()
}
