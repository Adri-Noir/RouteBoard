//
//  RouteFinderView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 29.06.2024..
//

import SwiftUI

struct RouteFinderView: View {
    @StateObject private var routeImageModel = RouteImageModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                GeometryReader { geometry in
                    ViewFinderView(image:  $routeImageModel.viewfinderImage )
                        .background(.black)
                }
                .task {
                    await routeImageModel.startCamera()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                .ignoresSafeArea()
                .statusBar(hidden: true)
                
                RouteFinderBottomInfoView(routeImageModel: routeImageModel)
            }
        }
    }
}

#Preview {
    RouteFinderView()
}
