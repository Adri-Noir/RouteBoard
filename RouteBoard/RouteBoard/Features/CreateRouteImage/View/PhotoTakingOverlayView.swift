//
//  PhotoTakingView.swift
//  RouteBoard
//
//  Created with <3 on 20.12.2024..
//

import SwiftUI

struct PhotoTakingOverlayView: View {
    @ObservedObject var createRouteImageModel: CreateRouteImageModel
    
    func removeAllPoints() {
        createRouteImageModel.canvasPoints.removeAll()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button() {
                    Task {
                        await createRouteImageModel.takePhoto()
                    }
                } label: {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .resizable()
                        .scaledToFill()
                    
                }
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
                .padding()
                
                Spacer()
                
                PhotoCaptureButton {
                    Task {
                        await createRouteImageModel.takePhoto()
                    }
                }
                .frame(width: 50, height: 50)
                .foregroundStyle(.white)
                .padding(EdgeInsets(top: 10, leading: -60, bottom: 10, trailing: 0))
                
                Spacer()
            }
        }
        .background(.black)
        .opacity(0.8)
        .frame(maxWidth: .infinity)
        .onAppear(perform: removeAllPoints)
    }
}
