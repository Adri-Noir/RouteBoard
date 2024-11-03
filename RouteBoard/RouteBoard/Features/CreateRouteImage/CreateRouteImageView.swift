//
//  CreateRouteImageView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.07.2024..
//

import SwiftUI


struct CameraViewFinder: View {
    @StateObject var createRouteImageModel: CreateRouteImageModel;
    
    var body: some View {
        GeometryReader { geometry in
            ViewFinderView(image:  $createRouteImageModel.viewfinderImage )
                .background(.black)
        }
        .task {
            await createRouteImageModel.camera.start()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }
}

struct CreateRouteImageView: View {
    @StateObject private var createRouteImageModel = CreateRouteImageModel()
    
    var body: some View {
        NavigationStack {
            CreateRouteOverlayView(createRouteImageModel: createRouteImageModel, content: CameraViewFinder(createRouteImageModel: createRouteImageModel))
        }
    }
}

#Preview {
    CreateRouteImageView()
}
