//
//  RouteFinderView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

import SwiftUI

struct RouteFinderView: View {
    @StateObject private var routeImageModel = RouteImageModel()
    private static let barHeightFactor = 0.15
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ViewFinderView(image:  $routeImageModel.viewfinderImage )
                    .background(.black)
            }
            .task {
                await routeImageModel.camera.start()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
}

#Preview {
    RouteFinderView()
}
